require 'support/capybara_app_helper'
require 'benchmark'

RSpec.describe "Benchmark" do
  before do
    setup_app(action: :turing)
    do |tracker|
      tracker.handler :track_all_the_things, { custom_key: 'SomeKey123' }
      tracker.handler :another_handler, { custom_key: 'AnotherKey42' }
    end
  end

  let(:expected_snippet_head) do
    <<-HTML.gsub(/^\s*/, '')
        <script type="text/javascript">
          myAwesomeFunction("tracks", "like", "turing", "SomeKey123");
        </script>
      </head>
    HTML
  end

  let(:expected_snippet_body) do
      <<-HTML.gsub(/^\s*/, '')
          <script type="text/javascript">
            anotherFunction("tracks-event-from-down-under", "AnotherKey42");
          </script>
        </body>
      </html>
    HTML
  end

  it "embeds the script tag lightning fast" do
    Benchmark.bmbm do |bm|
      bm.report 'inject' do
        1.times do
          visit '/'
          html = page.html.gsub(/^\s*/, '')
          expect(html).to include(expected_snippet_head)
          expect(html).to include(expected_snippet_body)
        end
      end
    end
  end
end
