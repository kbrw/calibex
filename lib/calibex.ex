defmodule Calibex do
  @moduledoc """
  Calibex allows you to handle ICal file format.

  In the same way as the `mailibex` library, Calibex allows bijective coding/decoding : 
  making it possible to modify an ical and to keep all fields and struct of the initial ical.

  The ICal elixir term is exactly a representation of the ICal file format : for instance : 

      [vcalendar: [[
        prodid: "-//Google Inc//Google Calendar 70.9054//EN",
        version: "2.0",
        calscale: "GREGORIAN", 
        vevent: [[
          dtstart: %DateTime{},
          dtend: %DateTime{},
          organizer: [cn: "My Name",value: "mailto:me@example.com"],
          attendee: [cutype: "INDIVIDUAL",role: "REQ-PARTICIPANT",partstat: "NEEDS-ACTION",rsvp: true, cn: "Moi",
                      "x-num-guests": 0, value: "mailto:me@example.com"],
        ]]]]]

  `encode/1` and `decode/1` parse and format an ICal from this terms : see
  functions doc to find encoding rules.

  Using this terms make it possible to handle all types of ICal files and any
  fields type. But the downside of this approach is that it can be cumbersome
  to create and handle this tree of keyword lists. To help you in this tasks,
  some helpers functions are provided : 

  - `new/1`
  - `new/2`
  - `new_root/1`
  - `new_root/2`
  - `request/1`
  - `request/2`


  ## Example usage : email event request generation 

  ```
  Calibex.request(dtstart: Timex.now, dtend: Timex.shift(Timex.now,hours: 1), summary: "Mon évènement",
            organizer: "arnaud.wetzel@example.com", attendee: "jeanpierre@yahoo.fr", attendee: "jean@ya.fr")
   |> Calibex.encode
  ```
  """

  @doc ~S"""
  Encode a tree of keyworks list with ICal rules : 

  - `KEY: [KW1,KW2]` a list of keyword list is encoded as multiple
    `BEGIN:KEY\nKW1\nEND:KEY\nBEGIN:KEY\nKW2\nEND:KEY`
  - `[K1: V1, K2: V2]` a keyword list is encoded as lines `K1:V1\nK2:V2`
  - `KEY: [K1, V1, K2: V2, value: VALUE]` a keyword list as leaf value is encoded as
     key value line with props : `KEY;K1=V1;K2=V2:VALUE`
  - `%DateTime{}` datetime values are encoded as UTC BasicISO string
  - `:atom1` atom values are encoded as upercase string `ATOM1`
  - `:key_1` atom keys are encoded as upercase string, `_` replaced with `-` : `KEY-1`
  """
  defdelegate encode(props), to: Calibex.Codec

  @doc """
  Decode an ICal UTF8 binary into a tree of keywork list with the same rules as
  `encode/1`, but inversed, excepted : 

  - all leaf values are not decoded: kept as string.
  """
  defdelegate decode(bin), to: Calibex.Codec

  @doc """
  Complete an event keyword list to form an ical nested kwlists :
  `fill_attrs` is a list of *key* atoms describing completion rules to be used.

  see `all_fill_attrs/0` doc to find allowed completion rules.
  """
  defdelegate new(event, fill_attrs), to: Calibex.Helper

  @doc "see `new/2`, default fill_attrs are 
      `[:prodid, :version, :calscale, :organizer, :attendee, :cutype, :role, :partstat, :rsvp, :x_num_guests]`"
  defdelegate new(event), to: Calibex.Helper

  @doc """
  same as `new/2`, but with a `REQUEST` method in order to allow email request
  ICS generation.
  """
  defdelegate request(event, fill_attrs), to: Calibex.Helper

  @doc """
  same as `new/1`, but with a `REQUEST` method in order to allow email request
  ICS generation.
  Default `fill_attrs` contains in addition `[:uid,:last_modified,:sequence,:dtstamp,:created,:status]`
  """
  defdelegate request(event), to: Calibex.Helper

  @doc """
  Complete an ical keyword list :
  `fill_attrs` is a list of *key* atoms describing completion rules to be used.

  see `all_fill_attrs/0` doc to find allowed completion rules.
  """
  defdelegate new_root(cal, fill_attrs), to: Calibex.Helper
  defdelegate new_root(cal), to: Calibex.Helper

  @doc """
  return all available transformation rules. There are 2 types :

  - the ones which set a default value if not defined otherwise (DEFAULT)
  - the ones which transform a given value if defined (TRANSFORM)

  Available rules are : 
  - `:last_modified`,`:dtstamp`,:`created` : DEFAULT to UTC now
  - `:sequence` : DEFAULT to 0
  - `:uid` : DEFAULT to all vals hexa sha1 of all event props
  - `:status` : DEFAULT to :confirmed
  - `:version`,`:calscale`,`:prodid`: DEFAULT to base ical attrs (`2.0`,`GREGORIAN`)
  - `:cutype`, `:role`, `:partstat`, `:rsvp`, `:x_num_guests`: DEFAULT to
     standard rsvp enabled attendee, waiting for event acceptance
  - `:organizer` TRANSFORM an email string into a `[cn: email,value: "mailto:"<>email]` props value.
  - `:attendee` TRANSFORM an email string into a `[cn: email,value: "mailto:"<>email]` props value.

  """
  defdelegate all_fill_attrs(), to: Calibex.Helper
end
