# frozen_string_literal: true

require 'test_helper'
require 'bundler'
require 'open3'

CURRENT_BRIDGETOWN_VERSION = '~> 0.15.0.beta2'
CURRENT_COMMIT = `git rev-parse HEAD`.freeze

class IntegrationTest < Minitest::Test
  include TailwindCss::IoTestHelpers

  def setup
    Rake.rm_rf(TEST_APP)
    Rake.mkdir_p(TEST_APP)
  end

  def read_test_file(filename)
    File.read(File.join(TEST_APP, filename))
  end

  def read_template_file(filename)
    File.read(File.join(TEMPLATES_DIR, filename))
  end

  def run_assertions
    tailwind = 'tailwind.config.js'
    test_tailwind_file = read_test_file(tailwind)
    template_tailwind_file = read_template_file(tailwind)

    assert_equal(test_tailwind_file, template_tailwind_file)

    webpack = 'webpack.config.js'
    test_webpack_file = read_test_file(webpack)
    template_webpack_file = read_template_file(webpack)

    assert_equal(test_webpack_file, template_webpack_file)

    styles = 'index.scss'
    styles_test_path = File.join('frontend', 'styles', styles)

    test_styles_file = read_test_file(styles_test_path)
    template_styles_file = read_template_file(styles)

    assert test_styles_file.include?(template_styles_file)
  end

  # def test_it_works_with_local_automation
  #   Bundler.with_original_env do
  #     Rake.cd TEST_APP

  #     # This has to overwrite `webpack.config.js` so it needs input
  #     simulate_stdin('y') do
  #       Rake.sh("bundle exec bridgetown new . --force --apply='../bridgetown.automation.rb'")
  #     end
  #   end

  #   run_assertions
  # end

  def test_it_works_with_remote_automation
    Bundler.with_original_env do
      Rake.cd TEST_APP
      Rake.sh('bundle exec bridgetown new . --force')

      # simulate_stdin does not work here, not sure why
      stdout, stderr, status = Open3.capture3('bundle exec bridgetown apply ../bridgetown.automation.rb',
                                              stdin_data: "y\n")

      puts stdout
      puts stderr
      puts status
    end

    run_assertions
  end

  #   # github_url = 'raw.githubusercontent.com'
  #   # user_and_reponame = 'ParamagicDev/bridgetown-plugin-tailwindcss'

  #   # file = 'bridgetown.automation.rb'

  #   # url = "#{github_url}/#{user_and_reponame}/#{current_commit_hash}/#{file}"

  #   # Rake.sh("bundle exec bridgetown apply #{url}")

  #   run_assertions
  # end
end
