# Calibex

Please read the doc at : [https://hexdocs.pm/calibex](https://hexdocs.pm/calibex)

**Handle exhaustively ICal format**: bijective coding/decoding for ICal
transformation, ICal email request and responses.

Simple algorithm for ICal encoding : *every ICal fields handled*.

## ICal Elixir bijective format

The ICal elixir term is an exact representation of the ICal file format.

For instance :

```elixir
[
  vcalendar: [
    [
      prodid: "-//Google Inc//Google Calendar 70.9054//EN",
      version: "2.0",
      calscale: "GREGORIAN",
      vevent: [
        [
          dtstart: %DateTime{},
          dtend: %DateTime{},
          organizer: [cn: "My Name", value: "mailto:me@example.com"],
          attendee: [
            cutype: "INDIVIDUAL",
            role: "REQ-PARTICIPANT",
            partstat: "NEEDS-ACTION",
            rsvp: true,
            cn: "Moi",
            "x-num-guests": 0,
            value: "mailto:me@example.com"
          ]
        ]
      ]
    ]
  ]
]
```

[`Calibex.encode/1`](https://hexdocs.pm/calibex/Calibex.html#encode/1)
and [`Calibex.decode/1`](https://hexdocs.pm/calibex/Calibex.html#decode/1)
parse and format an ICal from these terms : see functions doc to find encoding
rules.

Using this terms make it possible to handle all types of ICal files and any
fields type. But the downside of this approach is that it can be cumbersome
to create and handle this tree of keyword lists. To help you in this tasks,
some helpers functions are provided :

- [`Calibex.new/1`](https://hexdocs.pm/calibex/Calibex.html#decode/1)
- [`Calibex.new_root/1`](https://hexdocs.pm/calibex/Calibex.html#new_root/1)
- [`Calibex.request/1`](https://hexdocs.pm/calibex/Calibex.html#request/1)


## Example usage : email event request generation

```elixir
Calibex.request(
  dtstart: Timex.now(),
  dtend: Timex.shift(Timex.now(), hours: 1),
  summary: "Mon évènement",
  organizer: "arnaud.wetzel@example.com",
  attendee: "jeanpierre@yahoo.fr",
  attendee: "jean@ya.fr"
)
|> Calibex.encode()
```
