defmodule ExBfTest do
  use ExUnit.Case
  doctest ExBf

  import ExUnit.CaptureIO

  test "prints the value" do
    assert capture_io(fn ->
             ["." | List.duplicate(["+"], 65)]
             |> Enum.reverse()
             |> Enum.join()
             |> ExBf.parse()
           end) == "A"
  end

  test "calculates 2 + 5 and prints it out" do
    input = """
          ++
          > +++++
          [<+>-]
          ++++ ++++
          [
          < +++ +++
          > -
          ]
          < .
    """

    assert capture_io(fn -> ExBf.parse(input) end) == "7"
  end

  test "prints hello world" do
    input = """
    ++++++++            
    [
      >++++               
      [                   
        >++             
        >+++            
        >+++            
        >+              
        <<<<-           
      ]

      >+                  
      >+                  
      >-                  
      >>+                 
      [<]                 
                        
      <-                  
    ]

    >>.                 
    >---.                   
    +++++++..+++.           
    >>.                     
    <-.                     
    <.                      
    +++.------.--------.    
    >>+.                    
    >++.
    """

    assert capture_io(fn -> ExBf.parse(input) end) == "Hello World!\n"
  end
end
