defmodule Calibex.Helper do
  @moduledoc "Helper to easily create and modify ical keywork lists"

  @calendar_fill [:prodid, :version, :calscale]
  @attendee_fill [:organizer, :attendee, :cutype, :role, :partstat, :rsvp, :x_num_guests]
  @new_fill @calendar_fill ++ @attendee_fill
  @request_fill @new_fill ++ [:uid, :last_modified, :sequence, :dtstamp, :created, :status]
  def new(event, fill_attrs \\ @new_fill),
    do: fill_rec([vcalendar: [[vevent: [event]]]], fill_attrs)

  def request(event, fill_attrs \\ @request_fill),
    do: fill_rec([vcalendar: [[method: "REQUEST", vevent: [event]]]], fill_attrs)

  def new_root(cal, fill_attrs \\ @new_fill), do: fill_rec([vcalendar: [cal]], fill_attrs)

  def all_fill_attrs, do: @request_fill

  ## fill_rec recursively augment fields and add default fields if key matches `augment/3`, `default/2`
  def fill_rec(el, fill_attrs), do: fill_rec(el, Enum.group_by(fill_attrs, &parent/1), nil)

  def fill_rec([{_, _} | _] = props, fill_by_parent, parent) do
    props =
      Enum.map(props, fn {k, v} ->
        v =
          if fill_by_parent[parent] && k in fill_by_parent[parent] do
            augment(k, v, props)
          else
            v
          end

        {k, fill_rec(v, fill_by_parent, k)}
      end)

    case fill_by_parent[parent] do
      nil -> props
      tofill -> Enum.filter_map(tofill, &(!props[&1]), &{&1, default(&1, props)}) ++ props
    end
  end

  def fill_rec(l, fill_by_parent, parent) when is_list(l),
    do: Enum.map(l, &fill_rec(&1, fill_by_parent, parent))

  def fill_rec(v, _, _), do: v

  def augment(:organizer, bin, _vals) when is_binary(bin), do: [cn: bin, value: "mailto:#{bin}"]
  def augment(:attendee, bin, _vals) when is_binary(bin), do: [cn: bin, value: "mailto:#{bin}"]
  def augment(_, val, _vals), do: val

  def default(:uid, vals),
    do: :crypto.hash(:sha, :erlang.term_to_binary(vals)) |> Base.encode16(case: :lower)

  def default(:last_modified, _vals), do: Timex.now()
  def default(:sequence, _vals), do: 0
  def default(:dtstamp, _vals), do: Timex.now()
  def default(:created, _vals), do: Timex.now()
  def default(:status, _vals), do: :confirmed
  def default(:cutype, _vals), do: "INDIVIDUAL"
  def default(:role, _vals), do: "REQ-PARTICIPANT"
  def default(:partstat, _vals), do: "NEEDS-ACTION"
  def default(:rsvp, _vals), do: true
  def default(:x_num_guests, _vals), do: 0
  def default(:version, _vals), do: "2.0"
  def default(:calscale, _vals), do: "GREGORIAN"

  def default(:prodid, _vals),
    do: "-//KBRW//Calibex #{unquote(Mix.Project.config()[:version])}//EN"

  def default(_, _), do: ""

  def parent(k)
      when k in [
             :uid,
             :last_modified,
             :sequence,
             :dtstamp,
             :created,
             :status,
             :transp,
             :attendee,
             :organizer
           ],
      do: :vevent

  def parent(k) when k in [:cutype, :role, :partstat, :rsvp, :x_num_guests], do: :attendee
  def parent(k) when k in [:prodid, :version, :calscale], do: :vcalendar
end
