defmodule WDGParserTest do
  use ExUnit.Case, async: true

  @op """
  '<span class="quote">&gt;Free beginner resources to get started with HTML, CSS and JS</span><br>https://developer.mozilla.org/en-US<wbr>/docs/Learn - MDN is your friend for web dev fundamentals (go to the &quot;See also&quot; section for other Mozilla approved tutorials, like The Odin Project)<br>https://web.dev/learn/ - Guides by Google, you can also learn concepts like Accessibility, Responsive Design etc.<br>https://eloquentjavascript.net/Eloq<wbr>uent_JavaScript.pdf - A modern introduction to JavaScript<br>https://javascript.info/ - Quite a good JS tutorial<br>https://flexboxfroggy.com/ and https://cssgridgarden.com/ - Learn flex and grid in CSS<br><br><span class="quote">&gt;Resources for backend languages</span><br>https://www.phptutorial.net - A PHP tutorial<br>https://dev.java/learn/ - A Java tutorial<br>https://rentry.org/htbby - Links for Python and Go<br><br><span class="quote">&gt;Resources for miscellaneous areas</span><br>https://github.com/bradtraversy/des<wbr>ign-resources-for-developers - List of design resources<br>https://www.digitalocean.com/commun<wbr>ity/tutorials - Usually the best guides for everything server related<br><br><span class="quote">&gt;Staying up to date</span><br>https://cooperpress.com/publication<wbr>s/ - Several weekly newsletters for different subjects you can subscribe to<br>https://www.youtube.com/@Fireship - Short entertaining videos<br><br><span class="quote">&gt;Need help? Create an example and post the link</span><br>https://jsfiddle.net - if you need help with HTML/CSS/JS<br>https://3v4l.org - if you need help with PHP/HackLang<br>https://codesandbox.io - if you need help with React/Angular/Vue<br><br>We have our own website: https://wdg.one<br>Submit your project progress updates using this format in your posts, the scraper will pick it up:<br><pre class="prettyprint">:: my-project-title ::<br>dev:: anon<br>tools:: PHP, MySQL, etc.<br>link:: https://my.website.com<br>repo:: https://github.com/user/repo<br>progress:: Lorem ipsum dolor sit amet<br></pre><br><br><br>Previous: <a href="/g/thread/96142138#p96142138" class="quotelink">&gt;&gt;96142138</a>'
  """

  @op_around_pre """
  <pre class="prettyprint">:: my-project-title ::<br>dev:: anon<br>tools:: PHP, MySQL, etc.<br>link:: https://my.website.com<br>repo:: https://github.com/user/repo<br>progress:: Lorem ipsum dolor sit amet<br></pre>
  """

  @op_inside_pre """
  :: my-project-title ::<br>dev:: anon<br>tools:: PHP, MySQL, etc.<br>link:: https://my.website.com<br>repo:: https://github.com/user/repo<br>progress:: Lorem ipsum dolor sit amet
  """

  describe "is_scrape_target?/1" do
    test "correct target returns true" do
      assert WDG.Parser.is_scrape_target?(@op)
      assert WDG.Parser.is_scrape_target?(@op_around_pre)
      assert WDG.Parser.is_scrape_target?(@op_inside_pre)
      assert WDG.Parser.is_scrape_target?(":: my-project-title ::")
      assert WDG.Parser.is_scrape_target?("::this still works::")
    end

    test "incorrect target returns false" do
      assert not WDG.Parser.is_scrape_target?("my-project-title")
      assert not WDG.Parser.is_scrape_target?(": my-project-title :")
      assert not WDG.Parser.is_scrape_target?("shitpost")
    end
  end

  describe "extract_title/1" do
    test "it extracts title correctly" do
      assert WDG.Parser.extract_title(@op) == "my-project-title"
      assert WDG.Parser.extract_title(@op_around_pre) == "my-project-title"
      assert WDG.Parser.extract_title(@op_inside_pre) == "my-project-title"
      assert WDG.Parser.extract_title(":: Ligmanuts ::") == "Ligmanuts"
    end

    test "it extracts nothing when no match" do
      assert WDG.Parser.extract_title("shitpost") == nil
      assert WDG.Parser.extract_title("") == nil
      assert WDG.Parser.extract_title(":title:") == nil
    end
  end

  describe "extract_dev/1" do
    test "it extracts dev correctly" do
      assert WDG.Parser.extract_dev(@op) == "anon"
      assert WDG.Parser.extract_dev(@op_around_pre) == "anon"
      assert WDG.Parser.extract_dev(@op_inside_pre) == "anon"
      assert WDG.Parser.extract_dev("dev:: anon<br>") == "anon"
    end

    test "it extracts nothing when no match" do
      assert WDG.Parser.extract_dev("shitpost") == nil
      assert WDG.Parser.extract_dev("") == nil
      assert WDG.Parser.extract_dev("dev::<br>") == nil
    end
  end

  describe "extract_tools/1" do
    test "it extracts tools correctly" do
      assert WDG.Parser.extract_tools(@op) == "PHP, MySQL, etc."
      assert WDG.Parser.extract_tools(@op_around_pre) == "PHP, MySQL, etc."
      assert WDG.Parser.extract_tools(@op_inside_pre) == "PHP, MySQL, etc."
      assert WDG.Parser.extract_tools("tools:: tools<br>") == "tools"
    end

    test "it extracts nothing when no match" do
      assert WDG.Parser.extract_tools("shitpost") == nil
      assert WDG.Parser.extract_tools("") == nil
      assert WDG.Parser.extract_tools("tools::<br>") == nil
    end
  end

  describe "extract_link/1" do
    test "it extracts link correctly" do
      assert WDG.Parser.extract_link(@op) == "https://my.website.com"
      assert WDG.Parser.extract_link(@op_around_pre) == "https://my.website.com"
      assert WDG.Parser.extract_link(@op_inside_pre) == "https://my.website.com"
      assert WDG.Parser.extract_link("link:: https://ligma.nuts<br>") == "https://ligma.nuts"
    end

    test "it extracts nothing when no match" do
      assert WDG.Parser.extract_link("shitpost") == nil
      assert WDG.Parser.extract_link("") == nil
      assert WDG.Parser.extract_link("link::<br>") == nil
    end
  end

  describe "extract_repo/1" do
    test "it extracts repo correctly" do
      assert WDG.Parser.extract_repo(@op) == "https://github.com/user/repo"
      assert WDG.Parser.extract_repo(@op_around_pre) == "https://github.com/user/repo"
      assert WDG.Parser.extract_repo(@op_inside_pre) == "https://github.com/user/repo"
      assert WDG.Parser.extract_repo("repo:: https://ligma.nuts<br>") == "https://ligma.nuts"
    end

    test "it extracts nothing when no match" do
      assert WDG.Parser.extract_repo("shitpost") == nil
      assert WDG.Parser.extract_repo("") == nil
      assert WDG.Parser.extract_repo("repo::<br>") == nil
    end
  end

  describe "extract_progress/1" do
    test "it extracts progress correctly" do
      assert WDG.Parser.extract_progress(@op) == "Lorem ipsum dolor sit amet"
      assert WDG.Parser.extract_progress(@op_around_pre) == "Lorem ipsum dolor sit amet"
      assert WDG.Parser.extract_progress(@op_inside_pre) == "Lorem ipsum dolor sit amet"
      assert WDG.Parser.extract_progress("progress:: prog<br>") == "prog"

      assert WDG.Parser.extract_progress("progress:: this is <br> multiline <br>") ==
               "this is \n multiline"
    end

    test "it extracts nothing when no match" do
      assert WDG.Parser.extract_progress("shitpost") == nil
      assert WDG.Parser.extract_progress("") == nil
      assert WDG.Parser.extract_progress("progress::</span>") == nil
    end
  end

  describe "extract_post/1" do
    test "it extracts post correctly" do
      expected = %{
        title: "my-project-title",
        dev: "anon",
        tools: "PHP, MySQL, etc.",
        link: "https://my.website.com",
        repo: "https://github.com/user/repo",
        progress: "Lorem ipsum dolor sit amet"
      }

      Enum.each([@op, @op_around_pre, @op_inside_pre], fn op ->
        assert WDG.Parser.extract_post(op) == expected
      end)
    end

    test "partial edge case" do
      post = """
      :: tailwind is based! ::<br>tools:: tailwind<br>link:: https://tailwindcss.com/
      """

      expected = %{
        dev: nil,
        link: "https://tailwindcss.com/",
        progress: nil,
        repo: nil,
        title: "tailwind is based!",
        tools: "tailwind"
      }

      assert WDG.Parser.extract_post(post) == expected
    end

    test "it extracts nothing when no match" do
      assert WDG.Parser.extract_post("shitpost") == nil
      assert WDG.Parser.extract_post("") == nil
      assert WDG.Parser.extract_post("progress::<br>") == nil
    end

    test "desuarchive case" do
      post = ">>79961364\n:: dark-heya ::\ndev:: altilunium\ntools:: go, gin, melody\nlink:: http://dark-heya.ddns.net/\nrepo:: https://github.com/altilunium/darkhall\nprogress:: Yet another chat app. But the server is only routing the messages to current online users, not storing it. You can host it on your instance for your own private chat server."

      expected = %{
        title: "dark-heya",
        tools: "go, gin, melody",
        dev: "altilunium",
        link: "http://dark-heya.ddns.net/",
        progress:
          "Yet another chat app. But the server is only routing the messages to current online users, not storing it. You can host it on your instance for your own private chat server.",
        repo: "https://github.com/altilunium/darkhall"
      }

      assert WDG.Parser.extract_post(post) == expected
    end
  end
end
