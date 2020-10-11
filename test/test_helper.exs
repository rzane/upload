{:ok, _} = Upload.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Upload.Test.Repo, :manual)
ExUnit.start(exclude: [pending: true])
