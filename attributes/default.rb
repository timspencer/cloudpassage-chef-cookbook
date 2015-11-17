default[:cloudpassage][:agent_key] = ""
default[:cloudpassage][:tag] = ""
default[:cloudpassage][:deb_repo_url] = "https://packages.cloudpassage.com/debian debian main"
default[:cloudpassage][:rpm_repo_url] = "https://packages.cloudpassage.com/redhat/$basearch"
default[:cloudpassage][:deb_key_location] = "https://packages.cloudpassage.com/cloudpassage.packages.key"
default[:cloudpassage][:rpm_key_location] = "https://packages.cloudpassage.com/cloudpassage.packages.key"
default[:cloudpassage][:win_installer_location] = "https://packages.cloudpassage.com/windows/cphalo-3.2.10-win64.exe"
default[:cloudpassage][:grid] = "https://grid.cloudpassage.com/grid" 
# This proxy url needs to be in the format of "hostname:port" or "IP:port".  No http/https, etc. For example:
# default[:cloudpassage][:proxy_url] = "192.168.2.99:3128"
default[:cloudpassage][:proxy_url] = ""
default[:cloudpassage][:proxy_user] = "" 
default[:cloudpassage][:proxy_pass] = ""
default[:cloudpassage][:readonly] = 'false'
default[:cloudpassage][:usedns] = 'true'
default[:cloudpassage][:label] = ''

