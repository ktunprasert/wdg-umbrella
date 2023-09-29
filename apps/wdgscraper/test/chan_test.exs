defmodule WDGChanTest do
  use ExUnit.Case

  @correct ["/wdg/", "/wdg/ - Web Development General"]
  @incorrect ["/not-wdg/", "dont care", "", "Anonymous", "/mkg/"]

  describe "is_thread_wdg?/1" do
    test "correct general returns true" do
      @correct
      |> Enum.each(fn
        sub ->
          thread = %{"posts" => [%{"sub" => sub}]}
          assert WDG.Chan.is_thread_wdg?(thread)
      end)
    end

    test "incorrect general returns false" do
      @incorrect
      |> Enum.each(fn
        sub ->
          thread = %{"posts" => [%{"sub" => sub}]}
          assert not WDG.Chan.is_thread_wdg?(thread)
      end)
    end
  end

  describe "is_wdg?/1" do
    test "correct general returns true" do
      @correct
      |> Enum.each(fn sub -> assert WDG.Chan.is_wdg?(sub) end)
    end

    test "correct general returns false" do
      @incorrect
      |> Enum.each(fn sub -> assert not WDG.Chan.is_wdg?(sub) end)
    end
  end
end
