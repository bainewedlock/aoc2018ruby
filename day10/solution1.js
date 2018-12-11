
let tick_count = 0;
let points;
let w;
let h;
let xmin;
let xmax;
let ymin;
let ymax;
let size;
let factor;
let wstart = null;
let wmin = null;
let wmin_at_tick = null;
let points_at_wmin = null;


function setup() {
	frameRate(60);
  createCanvas(400, 400);

  let input_regex = /position=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>/
  points = input.split("\n").map(line => {
    var match = input_regex.exec(line);
    return new Point(...match.map(Number).slice(1));
  });

  prepare_points();
}

function prepare_points() {
  tick_count = start_tick;
  move_points(start_tick);
  tick_count = start_tick;
  update_data();
}

function move_points(speed) {
  points.forEach(p => p.tick(speed));
}

function update_data() {
  xmin = Math.min.apply(null, points.map(p => p.x));
  xmax = Math.max.apply(null, points.map(p => p.x));
  ymin = Math.min.apply(null, points.map(p => p.y));
  ymax = Math.max.apply(null, points.map(p => p.y));
  w = xmax-xmin+1;
  h = ymax-ymin+1;
  size = Math.max(w, h);
  factor = map(1, 0, size+1, 0, width)

  if (!wstart) wstart = w;
  if (!wmin || w < wmin) { 
    wmin = w;
    wmin_at_tick = tick_count;
    points_at_wmin = points.map(p => p.clone());
  }
}

function draw() {
  if (tick_count < end_tick) {
    tick_count += speed;
    move_points(speed);
  }

  update_data();

  translate(-xmin * factor, -ymin * factor);
	scale(factor, factor);
  background(50, 70, 70);

  fill(255);
  stroke(0);
  noStroke();
  points.forEach(p => p.draw());

  if (points_at_wmin) {
    stroke(10, 10, 80);
    points_at_wmin.forEach(p => p.draw());
  }

  resetMatrix();
}

class Point {
	constructor(x, y, xspeed, yspeed) {
		this.x = x;
		this.y = y;
    this.xspeed = xspeed;
    this.yspeed = yspeed;
	}
	draw() {
  	rect(this.x, this.y, 1, 1);		
	}
  tick(speed) {
    this.x += this.xspeed * speed;
    this.y += this.yspeed * speed;
  }
  clone() {
    return new Point(this.x, this.y, this.xspeed, this.yspeed);
  }
}

