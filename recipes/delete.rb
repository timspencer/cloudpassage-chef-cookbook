#
# Cookbook Name:: cloudpassage
# Recipe:: default
#
# Copyright 2015, CloudPassage
#

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

