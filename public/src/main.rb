
puts RUBY_VERSION # (Printed to the Web browser console)
stuff = JS.global[:document].getElementById('stuff')
stuff[:innerHTML] = "hello"
stuff[:style][:color] = "#ff0"

Hello.new
ZZ::Meow.new

div = JS.global[:document].createElement("div")
div[:innerText] = "click me"

body = JS.global[:document][:body]
body.appendChild(div)

div.addEventListener("click") do |event|
  puts event          # => # [object MouseEvent]
  puts event[:detail] # => 1
  div[:innerText] = "clicked!"
end

canvas = JS.global[:document].createElement("canvas")
canvas[:width] = 480
canvas[:height] = 272
canvas[:style][:imageRendering] = "pixelated"

body.appendChild(canvas)

ctx = canvas.getContext('2d')

thing = {
  stuff: stuff,
  ctx: ctx,
  prev: 0,
  x: 0,
  y: 10
}

def move(state)

  now = Time.now.to_f
  prev = state[:prev]

  state[:stuff][:innerText] = (now - prev).to_s

  state[:prev] = now


  ctx = state[:ctx]

  ctx[:fillStyle] = 'green'
  ctx.fillRect(0,0,480,272)
  ctx.fill

  ctx[:fillStyle] = 'black'
  ctx.fillRect(state[:x],state[:y],10,10)
  ctx.fill

  state[:x] += 1

  if state[:x] > 400
    state[:x] = 0
  end
end

JS.global.addEventListener("frame") do |event|
  # puts event[:target]
  move(thing)
end
