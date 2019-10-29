open Async

module Udp : sig
  module Client : sig
    type t

    val create : unit -> t Deferred.t

    val destroy : t -> unit Deferred.t

    val send : t -> Socket.Address.Inet.t -> Osc.Types.packet -> unit Deferred.t
  end

  module Server : sig
    type t

    val create : Socket.Address.Inet.t -> int -> t Deferred.t

    val destroy : t -> unit Deferred.t

    val recv :
      t ->
      ((Osc.Types.packet * Socket.Address.Inet.t, [
        | `Missing_typetag_string
        | `Unsupported_typetag of char
      ]) Result.result) Deferred.t
  end
end
