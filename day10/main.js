let input = 
`position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>`;

class Point {
	constructor(x, y, xspeed, yspeed) {
		this.x = x;
		this.y = y;
    this.xspeed = xspeed;
    this.yspeed = yspeed;
	}
	draw() {
	  fill(255);
 		stroke(0);
    noStroke();
  	rect(this.x, this.y, 1, 1);		
	}
  tick() {
    this.x += this.xspeed;
    this.y += this.yspeed;
  }
}

let points;
let w;
let h;
let xmin;
let xmax;
let ymin;
let ymax;
let size;
let factor;

function setup() {
	frameRate(10);
  createCanvas(400, 400);

  let input_regex = /position=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>/
  points = input.split("\n").map(line => {
    var match = input_regex.exec(line);
    return new Point(...match.map(Number).slice(1));
  });
  xmin = Math.min.apply(null, points.map(p => p.x));
  xmax = Math.max.apply(null, points.map(p => p.x));
  ymin = Math.min.apply(null, points.map(p => p.y));
  ymax = Math.max.apply(null, points.map(p => p.y));
  w = xmax-xmin+1;
  h = ymax-ymin+1;
	size = Math.max(w, h);
	factor = map(1, 0, size+1, 0, width)
  console.log(ymin);
}

function draw() {
  translate(-xmin * factor, -ymin * factor);
	scale(factor, factor);
  background(200, 220, 220);
  noFill();
  stroke(210, 230, 230);
  rect(0, 0, width, height);
  points.forEach(p => p.tick());
	points.forEach(p => p.draw());
}

