#!/usr/bin/env ruby
require 'open-uri'
require_relative '../build-binary-new/source_input'
require_relative '../build-binary-new/build_input'
require_relative '../build-binary-new/build_output'

def get_sha_from_text_file(url)
  open(url).read.match(/^(.*) .*linux-x64.tar.gz$/).captures.first.strip
end

source_input    = SourceInput.from_file('source/data.json')
build_input     = BuildInput.from_file("builds/binary-builds-new/#{source_input.name}/#{source_input.version}.json")
build_output    = BuildOutput.new(source_input.name)

build_input.copy_to_build_output

build_output.add_output("#{source_input.version}-bionic.json",
  {
    sha256: get_sha_from_text_file("https://nodejs.org/dist/v#{source_input.version}/SHASUMS256.txt"),
    url: "https://nodejs.org/dist/v#{source_input.version}/node-v#{source_input.version}-linux-x64.tar.gz"
  }
)

build_output.commit_outputs("Build #{source_input.name} - #{source_input.version} - io.buildpacks.stacks.bionic [##{build_input.tracker_story_id}]")
