require 'gosu'

class Keyboard
	attr_accessor :x, :y

	def initialize
		@x = 1
		@y = 0
	end

	def press(id)
		case id
		when Gosu::KB_LEFT
			return if @x != 0
			@x = -1
			@y = 0
		when Gosu::KB_RIGHT
			return if @x != 0
			@x = 1
			@y = 0
		when Gosu::KB_UP
			return if @y != 0
			@x = 0
			@y = -1
		when Gosu::KB_DOWN
			return if @y != 0
			@x = 0
			@y = 1
		end
	end

end

class Snake
	def initialize
		@cells = [{ x: 0, y: 0 }, { x: 1, y: 0 }]
		@x_max = Game::WIDTH / Game::CW
		@y_max = Game::HEIGHT / Game::CW
	end

	def draw(window)
		cw = Game::CW
		width = Game::WIDTH
		height = Game::HEIGHT

		@cells.each do |cell|
			window.draw_rect(cell[:x]* cw, cell[:y]* cw, cw, cw, Gosu::Color::GRAY)
			window.draw_rect((cell[:x]* cw) + 1, (cell[:y] * cw) + 1, cw - 2, cw - 2, Gosu::Color::GREEN)
		end
	end

	def ate?(apple)
	 	@cells.any? do |cell|
			cell[:x] == apple.x && cell[:y] == apple.y
		end
	end

	def move(keyboard)
		tail = @cells.first

		to_move = @cells.pop
		to_move[:x] = tail[:x] + keyboard.x
		to_move[:y] = tail[:y] + keyboard.y

		@cells.unshift(to_move)
	end

	def grow
		@cells.push(@cells.last.dup)
	end

	def collide?
		@cells.any? do |cell|
			cell[:x] < 0 || cell[:x] > @x_max || cell[:y] < 0 || cell[:y] > @y_max
		end
	end
end

class Apple
	attr_accessor :x, :y, :cw, :width, :height

	def initialize
		@width = Game::WIDTH
		@height = Game::HEIGHT
		@cw = Game::CW

		generate
	end

	def generate
		@x = (rand * (width - cw) / cw).round
		@y = (rand * (height - cw) / cw).round
	end

	def draw(window)
		window.draw_rect(x * cw, y * cw, cw, cw, Gosu::Color::BLACK)
		window.draw_rect((x * cw) + 2, (y * cw) + 2, cw - 4, cw - 4, Gosu::Color::RED)
	end

end

class Game < Gosu::Window
	DEFAULT_TIME = 0.10
	CW = 20
	WIDTH  = 640
	HEIGHT = 480

	def initialize
		super WIDTH, HEIGHT
		self.caption = "Snake Caption"
		start
	end
	
	def start
		# @font = Gosu::Font.new(20)
		@snake = Snake.new
		@last_tick = Time.new
		@keyboard = Keyboard.new
		@apple = Apple.new
		2.times { @snake.grow }
	end

	def update
		return if Time.now - @last_tick < DEFAULT_TIME
		@snake.move(@keyboard)

		if @snake.collide?
			start
		end

		if @snake.ate?(@apple)
			@apple.generate
			@snake.grow
		end

		@last_tick = Time.now
	end

	def button_down(id)
		@keyboard.press(id)
	end

	def draw
		# @font.draw('Olá, Mundo!', 10, 10, 1)
		@snake.draw(self)
		@apple.draw(self)
	end

end

Game.new.show