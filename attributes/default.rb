default[:cloudpassage][:agent_key] = ""
default[:cloudpassage][:tag] = ""
# This proxy url needs to be in the format of "hostname:port".  No http/https, etc. For example:
# default[:cloudpassage][:proxy_url] = "proxyhost.cloudpassage.com:3128"
default[:cloudpassage][:proxy_url] = ""
default[:cloudpassage][:proxy_user] = "" 
default[:cloudpassage][:proxy_pass] = ""
default[:cloudpassage][:deb_repo_uri] = "https://packages.cloudpassage.com/debian"
default[:cloudpassage][:deb_repo_distribution] = "debian"
default[:cloudpassage][:deb_repo_components] = ["main"]
default[:cloudpassage][:deb_key_location] = "https://packages.cloudpassage.com/cloudpassage.packages.key"
# rhel 5 based distros can't do https through a proxy
if (node[:platform_family] == 'rhel') && (node.platform_version.to_i < 6) && (default[:cloudpassage][:proxy_url] != "")
	default[:cloudpassage][:rpm_repo_url] = "http://packages.cloudpassage.com/redhat/$basearch"
	default[:cloudpassage][:rpm_key_location] = "http://packages.cloudpassage.com/cloudpassage.packages.key"
else
	default[:cloudpassage][:rpm_repo_url] = "https://packages.cloudpassage.com/redhat/$basearch"
	default[:cloudpassage][:rpm_key_location] = "https://packages.cloudpassage.com/cloudpassage.packages.key"
end
# Make sure that this url ends with the filename being in the format of cphalo-<versionnumber>-win64.exe!
# Otherwise, upgrades will break.
default[:cloudpassage][:win_installer_location] = "https://packages.cloudpassage.com/windows/cphalo-3.6.6-win64.exe"
default[:cloudpassage][:grid] = "https://grid.cloudpassage.com/grid" 
default[:cloudpassage][:readonly] = 'false'
default[:cloudpassage][:usedns] = 'true'
default[:cloudpassage][:label] = ''

# This is to try to force apt to update the cloudpassage repo
default[:cloudpassage][:refreshaptcache] = false

# Trigger a restart of all the daemons by changing this string here and pushing this cookbook out
# Any unique string will do.
default[:cloudpassage][:restart] = "2015-11-18-1406"
# Don't change this one, though.  Needed so initial run won't restart everything
default[:cloudpassage][:restarted] = "2015-11-18-1406"

# Trigger a reinstall of all the daemons by changing this string here and pushing this cookbook out
# Any unique string will do.
default[:cloudpassage][:reinstall] = "2015-11-18-1406"
# Don't change this one, though.  Needed so initial run won't restart everything
default[:cloudpassage][:reinstalled] = "2015-11-18-1406"

# Set this to true to get it to delete halo and all of it's files
# DO NOT DO THIS LIGHTLY
default[:cloudpassage][:delete] = false

