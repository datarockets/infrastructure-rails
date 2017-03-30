#!/usr/bin/env puma

bind 'unix://{{ deploy_dir }}{{ deploy_app_dir }}/shared/tmp/sockets/puma.sock'
directory '{{ deploy_dir  }}{{ deploy_app_dir }}/current'
rackup "{{ deploy_dir  }}{{ deploy_app_dir }}/current/config.ru"
pidfile "{{ deploy_dir  }}{{ deploy_app_dir }}/shared/tmp/pids/puma.pid"
state_path "{{ deploy_dir  }}{{ deploy_app_dir }}/shared/tmp/pids/puma.state"
stdout_redirect '{{ deploy_dir  }}{{ deploy_app_dir }}/shared/log/puma_access.log', '{{ deploy_dir  }}{{ deploy_app_dir }}/shared/log/puma_error.log', true

environment 'production'
threads {{ puma_threads }}
workers {{ puma_workers }}

preload_app!
prune_bundler

on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = "{{ deploy_dir  }}{{ deploy_app_dir }}/current/Gemfile"
end

# Required for preload_app!
on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end
