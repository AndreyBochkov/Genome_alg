/*
Генетический алгоритм. Автор: Андрей Бочков.
Предисловие:
  Генетические алгоритмы - особый класс алгоритмов, воспроизводящих эволюцию.
  Чаще всего в таких алгоритмах несколько агентов (виртуальных игроков), имеющих
  геном. Геном каждого определяет его поведение. По истечении определённого
  количества ходов или по другому условию воспроизводится поколение, притом, потомство
  (агентов с похожим на геном родителя геном) дают только самые лучшие из нынешних.
  В моей модели агенты - машины Тюринга, могущие перемещаться по своей ленте клеток,
  замкнутой с краёв и закрашивать клетки на ней. Те, кто закрасил больше,
  дают потомство. Геном первых случаен. Ленты отображаются горизонтально,
  друг над другом. Удачных симуляций!
Управление:
  Пробел: Пауза/Симуляция. Изначально пауза. !!! Симуляция довольно быстрая,
    не пугайтесь, если роботы внезапно сорвутся с места по нажатии пробела !!!
  Символ Q/Й: Проигрыш одной операции генома.
  Символ W/Ц: Проиграть операции генома до следующего поколения.
*/

public final int 
  genomeLength = 20, //Длина генома агента
  turingsNum = 21, //Кол-во агентов (до 24 при условии неизменности размеров окна)
  groundLength = 10; //Размер строки для каждого агента (до 24 при условии неизменности размеров окна)

public final float chanseToChangeGen = 0.5; //Изменчивость генома (от 0 до 1)

public final boolean pauseOnWin = true; //Ставить ли симуляцию на паузу, когда агент выполняет задание? "true" - да, "false" - нет.

//==================================================//

class turing {
  public int pos;
  public int[] genome = new int[genomeLength];
  public turing(boolean rgen) {
    pos = 0;
    if (rgen) {
      for (int i = 0; i < genomeLength; i ++) {
        genome[i] = round(random(-1, 3));
      }
    } else {
      for (int i = 0; i < genomeLength; i ++) {
        genome[i] = -1;
      }
    }
  }
}

public turing[] t = new turing[turingsNum];
public boolean[][] ground;
public int genrun, generation;
public boolean pause = true;

void setup() {
  ground = new boolean[turingsNum][groundLength];
  genrun = 0;
  generation = 0;
  for (int i = 0; i < turingsNum; i ++) {
    t[i] = new turing(true);
  }
  size(500, 500);
  noStroke();
  frame();
}

void draw() {
  if (!pause) {
    run(true);
  }
}

void frame() {
  background(0);
  for (int i = 0; i < turingsNum; i ++) {
    for (int j = 0; j < groundLength; j ++) {
      if (ground[i][j]) {
        fill(200);
      } else {
        fill(100);
      }
      rect(10+j*20, 10+i*20, 20, 20);
      if (t[i].pos == j) {
        fill(0, 255, 0);
        rect(15+j*20, 15+i*20, 10, 10);
      }
    }
  }
}

void run(boolean trueFr) {
  if (genrun == genomeLength) {
    generation();
    genrun = 0;
  } else {
    for (int i = 0; i < turingsNum; i ++) {
      switch (t[i].genome[genrun]) {
      case 0:
        if (t[i].pos != 0) {
          t[i].pos -= 1;
        } else {
          t[i].pos = groundLength-1;
        }
        //println(i, "й робот идет налево");
        break;
      case 1:
        ground[i][t[i].pos] = !ground[i][t[i].pos];
        //println(i, "й робот красит клетку");
        break;
      case 2:
        if (t[i].pos != groundLength-1) {
          t[i].pos += 1;
        } else {
          t[i].pos = 0;
        }
        //println(i, "й робот идет направо");
        break;
      default:
        //println(i, "й робот спит");
        break;
      }
    }
    genrun ++;
  }
  if (trueFr) {frame();}
}

void generation() {
  println("\nПоколение", generation);
  int[] marks = new int[turingsNum];
  for (int i = 0; i < turingsNum; i ++) {
    for (int j = 0; j < groundLength; j ++) {
      if (ground[i][j] == true) {
        marks[i] += 1;
      }
      //println(i, j, ground[i][j], marks[i]); 
    }
  }
  if (max(marks) == groundLength) {
    int index = find(marks, max(marks));
    println("===\nРобот", index, "справился с заданием! Геном:");
    String temp = "";
    for (int i = 0; i < genomeLength; i ++) {
      temp += t[index].genome[i] + " ";
    }
    println(temp, "\n===");
    pause = pauseOnWin;
  }
  int[] bestgenome = t[find(marks, max(marks))].genome;
  String temp = "";
  for (int i = 0; i < turingsNum; i ++) {
    temp += marks[i] + " ";
  }
  println("Оценки:", temp);
  String temp2 = "";
  for (int i = 0; i < genomeLength; i ++) {
    temp2 += bestgenome[i] + " ";
  }
  println("Лучший", ":", temp2);
  for (int i = 0; i < turingsNum; i ++) {
    t[i] = new turing(false);
    for (int j = 0; j < groundLength; j ++) {
      ground[i][j] = false;
    }
    arrayCopy(bestgenome, t[i].genome);
    //String temp = "";
    if (i > 0) {
      for (int j = 0; j < genomeLength; j ++) {
        if (random(0, 1) > (1-chanseToChangeGen)) {
          t[i].genome[j] = round(random(-1, 3));
        }
      }
    }
  }
  generation ++;
}

void keyPressed() {
  if (key == ' ') {
    pause = !pause;
  } else if ((key == 'q' || key == 'й') && pause) {
    run(true);
  } else if ((key == 'w' || key == 'ц') && pause) {
    int temp = generation;
    while (temp == generation) {
      run(false);
    }
    frame();
  }
}

int find(int[] arr, int pivot) {
  for (int i = 0; i < arr.length; i ++) {
    if (arr[i] == pivot) {
      return i;
    }
  }
  return -1;
}
