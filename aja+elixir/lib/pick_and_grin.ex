defmodule PickAndGrin do
  @bins_filename "../data/bins.tsv"
  @product_filename "../data/products.tsv"
  @product_bins_filename "../data/product-bins.tsv"

  def pick_products(picks) do
    product_bins = get_product_bins()

    picks
    |>Enum.map(fn ({product, quantity}) ->
      pick_product(product, quantity, product_bins)
    end)
  end

  def pick_product(product, requested_quantity, product_bins) do
    product_bins
    |> Map.get(product)
    |> Enum.sort_by(&elem(&1, 1), &>=/2)
    |> Enum.reduce_while({[], 0}, fn ({bin, available_quantity}, {bins, total_quantity}) ->
      if total_quantity < requested_quantity do
        {:cont, {[bin | bins], total_quantity + available_quantity}}
      else
        {:halt, {bins, total_quantity}}
      end
    end)
  end

  def get_product_bins do
    load_product_bins()
    |> Enum.reduce(%{}, fn ([product, bin, quantity], acc) ->
      value = case acc[product] do
        nil -> [{bin, quantity}]
        val -> [{bin, quantity} | val]
      end
      Map.put(acc, product, value)
    end)
  end

  def load_product_bins do
    bins = @product_bins_filename
    |> load_data
    |> Enum.map(fn ([bin, product, quantity]) ->
      [product, Bin.from_data(bin), String.to_integer(quantity)] end)
  end

  def load_bins do
    bins = @bins_filename
    |> load_data
    |> Enum.map(&List.first/1)
    |> Enum.map(&Bin.from_data/1)
  end

  def load_data(filename) do
    filename
    |> File.stream!
    |> CSV.decode(separator: ?\t)
    |> Enum.to_list
    |> Enum.map(&elem(&1, 1))
  end
end
