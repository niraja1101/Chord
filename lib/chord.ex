defmodule Newmodule do
  def main(args) do
    args |> read_arguments |> handle
  end

  defp read_arguments(args) do
    {_,arguments,_} = OptionParser.parse(args)
    arguments
  end

  def handle([]) do
    IO.puts "Please provide some arguments"
  end

  def handle(arguments) do
    numnodes = String.to_integer(Enum.at(arguments,0))
    numreq   = String.to_integer(Enum.at(arguments,1))


    IO.puts "\n\n\n\nWorking on getting the average hop count .....\n\n"
    Logic.start(numnodes, numreq)
    IO.puts "\n\n\n\n"
    
  end


end
