defmodule Wallaby.Integration.Browser.ScreenshotTest do
  use Wallaby.Integration.SessionCase, async: false

  setup %{session: session} do
    page =
      session
      |> visit("/")

    {:ok, page: page}
  end

  test "taking screenshots", %{page: page} do
    element =
      page
      |> take_screenshot
      |> find(Query.css("#header"))
      |> take_screenshot

    parent_screenshots =
      element
      |> Map.get(:parent)
      |> Map.get(:screenshots)

    element_screenshots =
      element
      |> Map.get(:screenshots)

    assert Enum.count(element_screenshots) == 1
    assert Enum.count(parent_screenshots) == 1

    Enum.each(element_screenshots ++ parent_screenshots, fn path ->
      assert File.exists?(path)
    end)

    File.rm_rf!("#{File.cwd!()}/screenshots")
  end

  test "users can specify the screenshot directory", %{page: page} do
    Application.put_env(:wallaby, :screenshot_dir, "shots")

    screenshots =
      page
      |> take_screenshot
      |> Map.get(:screenshots)

    assert screenshots |> Enum.count() == 1

    Enum.each(screenshots, fn path ->
      assert path =~ ~r/^shots\/(.*)$/
      assert File.exists?(path)
    end)

    Application.put_env(:wallaby, :screenshot_dir, nil)
    File.rm_rf!("#{File.cwd!()}/shots")
  end

  test "users can specify the screenshot name", %{page: page} do
    Application.put_env(:wallaby, :screenshot_dir, "shots")

    [screenshot_path] =
      page
      |> take_screenshot(name: "some_page")
      |> Map.get(:screenshots)

    assert screenshot_path == "shots/some_page.png"

    Application.put_env(:wallaby, :screenshot_dir, nil)
    File.rm_rf!("#{File.cwd!()}/shots")
  end

  test "filters out illegal characters in screenshot name", %{page: page} do
    Application.put_env(:wallaby, :screenshot_dir, "shots")

    [screenshot_path] =
      page
      |> take_screenshot(name: "some_page<>:\"/\\?*")
      |> Map.get(:screenshots)

    assert screenshot_path == "shots/some_page.png"

    Application.put_env(:wallaby, :screenshot_dir, nil)
    File.rm_rf! "#{File.cwd!}/shots"
  end
end
