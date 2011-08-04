puts("Hallo Welt!")


def collatz (x)
  y = 0
  while x!=1
    if x%2 == 0
      x /= 2
    else 
      x = x*3+1
    end
    y+=1
  end
  y
end


