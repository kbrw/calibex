defmodule CalibexTest do
  use ExUnit.Case

  test "ical encoding" do
    res =
      Calibex.encode(
        vcalendar: [
          [
            prodid: "-//Google Inc//Google Calendar 70.9054//EN",
            version: "2.0",
            calscale: "GREGORIAN",
            method: "REQUEST",
            vevent: [
              [
                dtstart: Timex.to_datetime({{2017, 5, 14}, {9, 0, 0}}, "Europe/Paris"),
                dtend: Timex.to_datetime({{2017, 5, 14}, {10, 0, 0}}, "Europe/Paris"),
                dtstamp: Timex.to_datetime({{2017, 5, 13}, {10, 52, 50}}, "UTC"),
                organizer: [cn: "Arnaud Wetzel", value: "mailto:arnaud.wetzel@example.com"],
                uid: "r30al68kn0b2epd9af6kqjg8rg@google.com",
                attendee: [
                  cutype: "INDIVIDUAL",
                  role: "REQ-PARTICIPANT",
                  partstat: "NEEDS-ACTION",
                  rsvp: true,
                  cn: "arnaudwetzel@examp.com",
                  "x-num-guests": 0,
                  value: "mailto:arnaudwetzel@examp.com"
                ],
                attendee: [
                  cutype: "INDIVIDUAL",
                  role: "REQ-PARTICIPANT",
                  partstat: "ACCEPTED",
                  rsvp: true,
                  cn: "Arnaud Wetzel",
                  x_num_guests: 0,
                  value: "mailto:arnaud.wetzel@example.com"
                ],
                created: Timex.to_datetime({{2017, 5, 13}, {10, 50, 32}}, "UTC"),
                description:
                  String.trim_trailing("""
                  Cet événement est associé à un appel vidéo Google Hangouts.
                  Participer : https://plus.google.com/hangouts/_/exampleexampl.com/arnaud-wetzel?hceid=YXJuYXVkLndldHplbEBrYnJ3YWR2ZW50dXJlLmNvbQ.r30al68kn0b2epd9af6kqjg8rg&hs=121

                  Affichez votre événement sur la page https://www.google.com/calendar/event?action=VIEW&eid=cjMwYWw2OGtuMGIyZXBkOWFmNmtxamc4cmcgYXJuYXVkd2V0emVsQHlhaG9vLmNvbQ&tok=MzEjYXJuYXVkLndldHplbEBrYnJ3YWR2ZW50dXJlLmNvbTdjMzQ0ZGFjN2FlYTM2OGI2NzEzNjAzZjVmNzk2NDVkMjA5ZDc0YjQ&ctz=Europe/Paris&hl=fr.
                  """),
                last_modified: Timex.to_datetime({{2017, 5, 13}, {10, 52, 49}}, "UTC"),
                location: "",
                sequence: 0,
                status: "CONFIRMED",
                summary: "c'est un évènement de test",
                transp: "OPAQUE"
              ]
            ]
          ]
        ]
      )

    assert res == File.read!("test/fixtures/invite.ics")
  end

  test "bijective codec" do
    ical = File.read!("test/fixtures/invite2.ics")
    assert ical |> Calibex.decode() |> Calibex.encode() == ical
  end

  # test "ical decoding" do
  #  res =Calibex.decode(File.read!("test/fixtures/invite2.ics"))
  #  IO.inspect(res, pretty: true, limit: :infinity)
  # end

  test "ical helpers" do
    req =
      Calibex.request(
        dtstart: Timex.now(),
        dtend: Timex.shift(Timex.now(), hours: 1),
        summary: "Mon évènement",
        organizer: "arnaud.wetzel@example.com",
        attendee: "jeanpierre@yahoo.fr",
        attendee: "jean@ya.fr"
      )

    assert [
             vcalendar: [
               [
                 prodid: "-//KBRW//Calibex 0.1.0//EN",
                 version: "2.0",
                 calscale: "GREGORIAN",
                 method: "REQUEST",
                 vevent: [
                   [
                     uid: _,
                     last_modified: %DateTime{},
                     sequence: 0,
                     dtstamp: %DateTime{},
                     created: %DateTime{},
                     status: :confirmed,
                     dtstart: %DateTime{},
                     dtend: %DateTime{},
                     summary: "Mon évènement",
                     organizer: [
                       cn: "arnaud.wetzel@example.com",
                       value: "mailto:arnaud.wetzel@example.com"
                     ],
                     attendee: [
                       cutype: "INDIVIDUAL",
                       role: "REQ-PARTICIPANT",
                       partstat: "NEEDS-ACTION",
                       rsvp: true,
                       x_num_guests: 0,
                       cn: "jeanpierre@yahoo.fr",
                       value: "mailto:jeanpierre@yahoo.fr"
                     ],
                     attendee: [
                       cutype: "INDIVIDUAL",
                       role: "REQ-PARTICIPANT",
                       partstat: "NEEDS-ACTION",
                       rsvp: true,
                       x_num_guests: 0,
                       cn: "jean@ya.fr",
                       value: "mailto:jean@ya.fr"
                     ]
                   ]
                 ]
               ]
             ]
           ] = req
  end
end
