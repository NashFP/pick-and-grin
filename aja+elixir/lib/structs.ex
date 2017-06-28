defmodule Bin do
  defstruct id: nil,
            warehouse: nil,
            room: nil,
            bay: nil,
            shelf: nil,
            position: nil,
            size: nil

  def from_data(bin_str) do
    ~r/W(\w+)-R(\w+)-B(\w+)-S(\w+)-(\w+)-(\w+)/
    |> Regex.scan(bin_str)
    |> List.first
    |> (fn ([id, w, r, b, s, p, size]) -> %__MODULE__{
      id: id,
      warehouse: w,
      room: r,
      bay: b,
      shelf: s,
      position: p,
      size: size,
    } end).()
  end
end
