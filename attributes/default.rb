default[:cloudpassage][:agent_key] = ""
default[:cloudpassage][:tag] = ""
default[:cloudpassage][:deb_repo_uri] = "https://packages.cloudpassage.com/debian"
default[:cloudpassage][:deb_repo_distribution] = "debian"
default[:cloudpassage][:deb_repo_components] = ["main"]
default[:cloudpassage][:rpm_repo_url] = "https://packages.cloudpassage.com/redhat/$basearch"
default[:cloudpassage][:deb_key_location] = "https://packages.cloudpassage.com/cloudpassage.packages.key"
default[:cloudpassage][:rpm_key_location] = "https://packages.cloudpassage.com/cloudpassage.packages.key"
default[:cloudpassage][:win_installer_location] = "https://packages.cloudpassage.com/windows/cphalo-3.2.10-win64.exe"
default[:cloudpassage][:grid] = "https://grid.cloudpassage.com/grid" 
# This proxy url needs to be in the format of "hostname:port".  No http/https, etc. For example:
# default[:cloudpassage][:proxy_url] = "proxyhost.cloudpassage.com:3128"
default[:cloudpassage][:proxy_url] = ""
default[:cloudpassage][:proxy_user] = "" 
default[:cloudpassage][:proxy_pass] = ""
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

