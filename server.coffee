module.exports = ->
  # install redis server from apt package repo
  @then @install, 'redis-server'

  # bind to public interface
  @then @execute, 'sed -i "s/bind 127.0.0.1/bind 0.0.0.0/" /etc/redis/redis.conf', sudo: true
  @then @execute, 'service redis-server restart', sudo: true # apply changes
