open Core
open Async

module Io = struct
  type 'a t = 'a Deferred.t
  let (>>=) = (>>=)
  let (>|=) = (>>|)
  let return x = return x
end

module UdpTransport = struct
  module Io = Io
  open Io

  type sockaddr = Socket.Address.Inet.t

  module Client = struct
    type t = {
      fd: Fd.t;
    }

    let create () =
      let socket = Socket.create Socket.Type.udp in
      let fd = Socket.fd socket in
      return {fd}

    let destroy {fd} =
      Fd.close fd

    let send_string client addr data =
      match Udp.sendto () with
      | Ok writer ->
          let iobuf = Iobuf.of_string data in
          writer client.fd iobuf addr
      | Error _ ->
          (* TODO *)
          return ()
  end

  module Server = struct
    type t = {
      socket : ([`Bound], sockaddr) Socket.t;
      fd: Fd.t;
      capacity : int;
    }

    let create addr capacity =
      let socket = Udp.bind addr in
      let fd = Socket.fd socket in
      return {socket; fd; capacity}

    let destroy server =
      return @@ Socket.shutdown server.socket `Both

    let recv_string {capacity; fd; _} =
      let stop_ivar = Ivar.create () in
      let stop = Ivar.read stop_ivar in
      let message = Ivar.create () in
      let config = Udp.Config.create ~capacity ~stop ~max_ready:1 () in
      Udp.recvfrom_loop ~config fd (fun buf sockaddr ->
        Ivar.fill stop_ivar ();
        Ivar.fill message (Iobuf.to_string buf, sockaddr))
      >>= (function
        | Closed -> failwith "TODO"
        | Stopped ->
            Ivar.read message)
  end
end

module Udp = Osc.Transport.Make(UdpTransport)
