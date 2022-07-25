#!/usr/bin/env rake

require "bundler/gem_helper"

namespace "doppler-env" do
  Bundler::GemHelper.install_tasks name: "doppler-env"
end

task build: ["dopplerenv:build"]
task install: ["dopplerenv:install"]
task release: ["dopplerenv:release"]