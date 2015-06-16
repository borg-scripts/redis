module.exports = ->
  # install redis server from source
  redis_version = "redis-3.0.2"
  file = "#{redis_version}.tar.gz"
  @then @download "http://download.redis.io/releases/#{file}",
    to: "/tmp/#{file}"
    checksum: "93e422c0d584623601f89b956045be158889ebe594478a2c24e1bf218495633f"
    owner: 'root'
    group: 'root'
    mode: '0644'
    sudo: true

  @then @execute "cd /tmp; tar zxvf #{file}"
  @then @execute "cd /tmp/#{redis_version}; sudo make install"

  @then @directory "/etc/redis",
    recursive: true
    owner: 'root'
    group: 'root'
    mode: '0755'
    sudo: true

  @then @directory "/var/redis/6379",
    recursive: true
    owner: 'root'
    group: 'root'
    mode: '0755'
    sudo: true

  # install configuration
  conf_file = "/etc/redis/6379.conf"
  @then @remote_file_exists conf_file, sudo: true, false: =>
    @then @execute "sudo cp /tmp/#{redis_version}/redis.conf #{conf_file}"
    @then @replace_line_in_file conf_file, sudo: true, find: '^# bind 127.0.0.1', replace: "bind 0.0.0.0"
    @then @replace_line_in_file conf_file, sudo: true, find: '^daemonize', replace: "daemonize yes"
    @then @replace_line_in_file conf_file, sudo: true, find: '^pidfile', replace: "pidfile /var/run/redis_6379.pid"
    @then @replace_line_in_file conf_file, sudo: true, find: '^logfile', replace: "logfile /var/log/redis_6379.log"
    @then @replace_line_in_file conf_file, sudo: true, find: '^dir', replace: "dir /var/redis/6379"

  # install init script
  initd_file = "/etc/init.d/redis_6379"
  @then @remote_file_exists initd_file, sudo: true, false: =>
    @then @execute "sudo cp /tmp/#{redis_version}/utils/redis_init_script #{initd_file}"

  # auto-start on reboot
  @then @execute "sudo update-rc.d redis_6379 defaults"

  # start service now
  @then @execute "sudo service redis_6379 start"
