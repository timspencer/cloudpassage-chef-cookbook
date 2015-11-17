#
# Cookbook Name:: cloudpassage
# Recipe:: default
#
# Copyright 2015, CloudPassage
# Before we get this party started, set the environment variable for proxy...

# First we build the proxy string
if node[:cloudpassage][:proxy_url] != ""
    ENV['http_proxy'] = "http://#{node[:cloudpassage][:proxy_url]}/"
    if (node[:cloudpassage][:proxy_user] != "") && (node[:cloudpassage][:proxy_pass] != "")
        proxy_string_lin = "--proxy=\"#{node[:cloudpassage][:proxy_url]}\" --proxy-user=\"#{node[:cloudpassage][:proxy_user]}\" --proxy-password=\"#{node[:cloudpassage][:proxy_pass]}\""
        proxy_string_win = "/proxy=\"#{node[:cloudpassage][:proxy_url]}\" /proxy-user=\"#{node[:cloudpassage][:proxy_user]}\" /proxy-password=\"#{node[:cloudpassage][:proxy_pass]}\""
    else
        proxy_string_lin = "--proxy=\"#{node[:cloudpassage][:proxy_url]}\""
        proxy_string_win = "/proxy=\"#{node[:cloudpassage][:proxy_url]}\""
    end
else
    proxy_string_lin = ""
    proxy_string_win = ""
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
else
    tag_string_lin = ''
    tag_string_win = ''
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
		action :nothing
	end
        apt_repository 'cloudpassage' do
            uri node[:cloudpassage][:deb_repo_url]
            key node[:cloudpassage][:deb_key_location] 
	    notifies :run, 'execute[refresh_apt_repos]'
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
            action :install
        end

        # We'll configure it here.  The service will be started at the end.
        execute "cphalo-config" do
            command "sudo /opt/cloudpassage/bin/configure #{startup_opts_lin}"
            action :run
        end

    when "windows"
        p_serv_name = "CloudPassage Halo Agent"
        startup_opts_win = "/agent-key=#{node[:cloudpassage]['agent_key']} #{tag_string_win} /grid=\"#{node[:cloudpassage][:grid]}\" #{proxy_string_win}" 
        windows_package 'CloudPassage Halo' do
            source node[:cloudpassage][:win_installer_location]
            options "/S #{startup_opts_win} /NOSTART"
            installer_type :custom
            action :install
        end
end

# Now we start the agent using the platform's service manager!
service "#{p_serv_name}" do
    action ["enable", "start"]
end

