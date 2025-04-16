# frozen_string_literal: true

class Explicit::MCPServer::Transport::Fake
  def send_result(result)
    raise ::NotImplementedError
  end

  def send_error(error)
    raise ::NotImplementedError
  end
end
