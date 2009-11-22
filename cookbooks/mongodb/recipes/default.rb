#
# Cookbook Name:: mongodb
# Recipe:: default


directory "/data/mongodb/master" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0755
  recursive true
end
directory "/data/mongodb/master/log" do
  owner node[:owner_name]
  group node[:owner_name]
  mode 0755
  recursive true
end

#directory "/data/slave" do
  #owner node[:owner_name]
  #group node[:owner_name]
  #mode 0755
  #recursive true
#end

execute "install-mongodb" do
  command %Q{
    pushd /usr/local
    wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-1.0.1.tgz
    tar xf mongodb-linux-x86_64-1.0.1.tgz
    rm mongodb-linux-x86_64-1.0.1.tgz
    popd
  }
  not_if { File.directory?('/usr/local/mongodb-linux-x86_64-1.0.1/bin/mongod') }
end

remote_file "/etc/init.d/mongodb" do
  source "mongodb"
  owner "root"
  group "root"
  mode 0755
end

template "/etc/conf.d/mongodb" do
  owner 'root'
  group 'root'
  mode 0644
  source "mongodb.conf.erb"
  variables({
    :data => "/data/mongodb/master",
    :log => "/data/mongodb/master/log/mongodb.log",
    :pid_file => "/data/master/mongodb.pid",
    :user => node[:owner_name],
    :ip => '0.0.0.0',
    :port => 37017,
  })
end

execute "add-mongodb-to-default-run-level" do
  command %Q{
    rc-update add mongodb default
  }
  not_if "rc-status | grep mongodb"
end

execute "ensure-mongodb-is-running" do
  command %Q{
    /etc/init.d/mongodb start
  }
  not_if "pgrep mongod"
end
