#
# Cookbook Name:: cloudpassage
# Recipe:: default
#
# Copyright 2015, CloudPassage
#

# Nuke everything if we set the delete attribute
if node[:cloudpassage][:delete]
	# nuke the package (linux package shuts down halo already)
	case node[:os]
	when 'linux'
		package 'cphalo' do
			if node[:platform_family] == 'debian'
				action :purge
			else
				action :remove
			end
		end
	when 'windows'
		# stop the service to be sure
		service 'cphalo' do
		    action ["disable", "stop"]
		end
		windows_package 'CloudPassage Halo' do
			action :remove
		end
	end

	# don't process the rest of the recipe
	return
end

# Before we get this party started, set the environment variable for proxy...
# First we build the proxy string
proxy_string_win = ''
proxy_string_lin = ''
if node[:cloudpassage][:proxy_url] != ""
    ENV['http_proxy'] = "http://#{node[:cloudpassage][:proxy_url]}/"
    if (node[:cloudpassage][:proxy_user] != "") && (node[:cloudpassage][:proxy_pass] != "")
        proxy_string_lin = "--proxy=\"#{node[:cloudpassage][:proxy_url]}\" --proxy-user=\"#{node[:cloudpassage][:proxy_user]}\" --proxy-password=\"#{node[:cloudpassage][:proxy_pass]}\""
        proxy_string_win = "/proxy=\"#{node[:cloudpassage][:proxy_url]}\" /proxy-user=\"#{node[:cloudpassage][:proxy_user]}\" /proxy-password=\"#{node[:cloudpassage][:proxy_pass]}\""
    else
        proxy_string_lin = "--proxy=\"#{node[:cloudpassage][:proxy_url]}\""
        proxy_string_win = "/proxy=\"#{node[:cloudpassage][:proxy_url]}\""
    end
end

# Set some "tags" in the node
case node.platform
when 'oracle'
    node.default.cloudpassage.tag = "oel#{node.platform_version.to_i}"
when 'ubuntu'
    node.default.cloudpassage.tag = 'ubuntu14'
when 'windows'
    if node.platform_version.to_f >= 6.2
        node.default.cloudpassage.tag = 'win2012'
    else
        node.default.cloudpassage.tag = 'win2008r2'
    end
end

# Next we determine the server tag string
if node[:cloudpassage][:tag] != ''
    tag_string_lin = "--tag=#{node[:cloudpassage][:tag]}"
    tag_string_win = "/tag=#{node[:cloudpassage][:tag]}"
end


# Set up repositories for Linux
case node[:platform_family]
    when "debian"
	if node[:cloudpassage][:proxy_url] != ""
		directory '/etc/apt/apt.conf.d' do
			recursive true
		end
		file '/etc/apt/apt.conf.d/01proxy' do
			content "Acquire::http::Proxy \"http://#{node[:cloudpassage][:proxy_url]}/\";"
		end
	end
	execute 'refresh_apt_repos' do
		command 'apt-get update'
		if node[:cloudpassage][:refreshaptcache] == false
			action :nothing
		end
	end
        apt_repository 'cloudpassage' do
            uri node[:cloudpassage][:deb_repo_uri]
            distribution node[:cloudpassage][:deb_repo_distribution]
            components node[:cloudpassage][:deb_repo_components]
            if node[:cloudpassage][:proxy_url] != ""
                key_proxy "http://#{node[:cloudpassage][:proxy_url]}/"
            end
            key node[:cloudpassage][:deb_key_location] 
	    # we really shouldn't need this next line.  May take out after testing some more.
	    notifies :run, 'execute[refresh_apt_repos]', :immediately
        end
    when "rhel"
        yum_repository 'cloudpassage' do
            description  "CloudPassage Halo Repository"
            baseurl  "#{node[:cloudpassage][:rpm_repo_url]}"
            gpgkey  "#{node[:cloudpassage][:rpm_key_location]}"
            action :create
            if node[:cloudpassage][:proxy_url] != ""
                proxy "http://#{node[:cloudpassage][:proxy_url]}/"
            end
        end
end

# Install and register the Halo agent
case node[:platform_family]
    when "debian", "rhel"
        p_serv_name = "cphalod"
        startup_opts_lin = "--agent-key=#{node[:cloudpassage]['agent_key']} #{tag_string_lin} --grid=\"#{node[:cloudpassage][:grid]}\" #{proxy_string_lin} --read-only=#{node[:cloudpassage]['readonly']} --dns=#{node[:cloudpassage]['usedns']}" 

        package 'cphalo' do
            action :upgrade
	    notifies :restart, "service[#{p_serv_name}]", :delayed
        end

        # We'll configure it here.  The service will be started at the end.
        execute "cphalo-config" do
            command "sudo /opt/cloudpassage/bin/configure #{startup_opts_lin}"
            action :run
	    # don't reconfigure if it's already been run
	    not_if "test -f /opt/cloudpassage/data/store.db.vector"
        end

    when "windows"
	p_serv_name = "cphalo"

	# need this for windows, because it doesn't shut down right away
	execute 'sleep10' do
		command 'sleep 10'
		action :nothing
	end

	# force a reinstall on windows if we've changed the reinstall string
	ruby_block "force_reinstall" do
	    only_if { node[:cloudpassage][:reinstall] != node[:cloudpassage][:reinstalled] }
	    block do
		node.set[:cloudpassage][:reinstalled] = node[:cloudpassage][:reinstall]
	    end
	    notifies :remove, "windows_package[CloudPassage Halo]", :immediately
	    notifies :run, "execute[sleep10]", :immediately
	end

	stdout,stderr,status = Open3.capture3('c:\windows\system32\sc.exe','query','cphalo')
	if status.exitstatus == 0
		# figure out the version of the installer
		win_installer_version = node[:cloudpassage][:win_installer_location].gsub(/.*cphalo-(\d*\.\d*\.\d*)-win64.exe/, '\1')
		
		# reinstall/upgrade here
		windows_package 'CloudPassage Halo' do
		    source node[:cloudpassage][:win_installer_location]
		    options "/S"
		    version win_installer_version
		    installer_type :custom
		    notifies :stop, "service[#{p_serv_name}]", :immediately
		    notifies :start, "service[#{p_serv_name}]", :immediately
		end
	else
		# fresh install here
		windows_package 'CloudPassage Halo' do
		    source node[:cloudpassage][:win_installer_location]
		    options "/S /daemon-key=#{node[:cloudpassage]['agent_key']} #{tag_string_win} /grid=\"#{node[:cloudpassage][:grid]}\" #{proxy_string_win} /NOSTART"
		    installer_type :custom
		    action :install
		end
	end
end

# force a restart if we've changed the restart string
ruby_block "force_restart" do
    only_if { node[:cloudpassage][:restart] != node[:cloudpassage][:restarted] }
    block do
        node.set[:cloudpassage][:restarted] = node[:cloudpassage][:restart]
    end
    notifies :restart, "service[#{p_serv_name}]"
end


# Now we start the agent using the platform's service manager!
# We ignore failure because some init/systemd things return nonzero while starting an already started service (ugly)
service "#{p_serv_name}" do
    action ["enable", "start"]
    supports :status => true
end

