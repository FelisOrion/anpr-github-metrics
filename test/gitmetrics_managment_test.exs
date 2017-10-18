defmodule Gitmetrics.ManagmentTest do
  use Gitmetrics.DataCase

  alias Gitmetrics.Managment

  test "get repo and organizzazione from link" do
    assert Managment.init_url("") == {"italia", "anpr"}
    assert Managment.init_url(nil) == {"italia", "anpr"}
    assert Managment.init_url("https://github.com/ueberauth/guardian") == {"ueberauth", "guardian"}
  end

  test "test github respons" do
    assert Managment.can_i_send?({401, "error msg"}) == {:error, :bad_credintial}
    assert Managment.can_i_send?({403, "error msg"}) == {:error, :limit}
    assert Managment.can_i_send?({404, "error msg"}) == {:error, :not_found}
    assert Managment.can_i_send?([1, 2, 4]) == {:ok, [1, 2, 4]}
  end
end
