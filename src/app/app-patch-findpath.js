window.graph = {};

window.init = function() {
  console.log('init()');
  dinastyInit();
  resetInit();

  // Создание графа. На выходе - отображение из id в объект { color: int, links: array[id] }.
  // Зная id персоны можно получить всех её близких родственников:
  //   var family = graph[id].links;
  // Поле color используется при поиске пути между объектами.
  //
  // Если отец (или мать) заданы через тильду:
  //   father: ~ 114,
  // то устанавливается только родительская связь. Другие дети персоны 114 не считаются
  // родственниками этой персоны.
  //
  // Если супругов несколько:
  //   couple: "86, 104",
  // то устанавливается связь с каждым из супругов, но не между ними. Обе жены Эрнста Людвига
  // связаны через него, но не напрямую.
  //
  // Если супруги заданы через тильду:
  //   couple: "~81, ~30",
  // то связь не устанавливается.
  //
  persons_data.forEach(function(e) {
    var links = [],
        toInt = function (s) { return parseInt(s); },
        getParent = function (s) { return typeof s === 'string'? toInt(s.replace(/~/g,'')): s },
        getId = function (p) { return p.id; };

    // Parents
    e.father && links.push(getParent(e.father));
    e.mother && links.push(getParent(e.mother));

    // Spouse
    if (e.couple > 0)
      links.push(e.couple);
    else if (typeof e.couple === 'string')
      links = links.concat(e.couple.split(/,/g).map(toInt)).filter(function(x) { return x; });

    // Children
    var children = persons_data.filter(function (child) {
        return getParent(child.father) == e.id || getParent(child.mother) == e.id;
      }).map(getId);

    // Siblings
    var siblings = persons_data.filter(function (child) {
        return child.id != e.id // Skip self
          && ((e.father > 0 && child.father == e.father)
          || (e.mother > 0 && child.mother == e.mother));
      }).map(getId);

    //console.log(e.id + " " + e.name + " " + graph[e.id].links + " children " + children + " siblings " + siblings);

    graph[e.id] = {
      color: 0,
      links: links.concat(children, siblings)
    };
  });

  // Обратный путь.
  // Просто ищем среди членов семьи любого, у кого цвет равен цвету from минус шаг.
  // Запоминаем индекс. Продолжаем поиск с той персоны, которую нашли.
  // Если на входе graph[from].color == 4, то сначала ищем любого родственника с color == 3,
  // Затем у этого родственника ищем родственника с color == 2 и, наконец, с color == 1.
  // Это та персона, от которой нужно построить путь.
  //
  // Если цвет отрицательный, то идём до -1 и оказываемся в персоне, к которой нужно строить путь.
  // Поскольку в обоих случаях путь собирается от середины к краю, то для положительного пути
  // его нужно развернуть, чтобы он был от начала до середины. Путь от середины до конца не меняем.
  //
  function mkPath(from) {

    var path = [from];
    var step = graph[from].color > 0? +1: -1;

    while (graph[from].color != step) {
      var color = graph[from].color - step;
      var from = graph[from].links.find(function(id) { return graph[id].color == color; });
      path.push(from);
    }

    // Positive part must be in the reverse order.
    return step > 0? path.reverse(): path;
  }

  // Поиск пути от персоны id1 к персоне id2.
  // 1. Обнуляем цвета у всех персон;
  // 2. Помечаем начало пути цветом +1, конец цветом -1;
  // 3. Составляем два списка. В первом изначально только id1, во втором id2;
  // 4. Если среди родственников всех, кто в списке, найден кто-то с цветом противоположного знака,
  //    то строим два отрезка: от того, у кого нашёлся антипод до id1 и от антипода до id2;
  // 5. Если никто из родственников не антипод, то всех, кто ещё _не_был_ окрашен, добавляем в новый список.
  // 6. Повторям пункты 4,5 пока не будет найден маршрут либо пока не окрасим всех.
  //
  function findPath(id1, id2) {
    // Self ref
    if (id1 === id2)
      return [id1];

    // Make sure that both persons are exist
    if (!graph[id1] || !graph[id2])
      return;

    // Reset Graph
    for (id in graph) {
      graph[id].color = 0;
    }

    // Mark initail vertices
    graph[id1].color = +1;
    graph[id2].color = -1;

    // Start from single elemnt lists.
    var pList = [id1];
    var nList = [id2];

    var ret;
    for (var step = 2; !ret && (pList.length || nList.length); ++step) {
      var pNext = [];
      pList.find(function(p) {
        return graph[p].links.find(function(id) {
          if (graph[id].color < 0) {
            ret = mkPath(p).concat(mkPath(id));
            return true;
          }
          
          if (graph[id].color == 0) {
            graph[id].color = step;
            pNext.push(id);
          }
        });
      });
      pList = pNext;

      if (ret)
        break;

      var nNext = [];
      nList.find(function(n) {
        return graph[n].links.find(function(id) {
          if (graph[id].color > 0) {
            ret = mkPath(id).concat(mkPath(n));
            return true;
          }
          
          if (graph[id].color == 0) {
            graph[id].color = -step;
            nNext.push(id);
          }
        });
      });
      nList = nNext;
    }

    return ret;
  }

  // Some tests
  "-1,0;1,1;1,2;1,3;2,3;3,4;1,29;45,2;50,114;38,92;92,65".split(/;/g).forEach(function(pair) {
    var ids = pair.split(/,/);
    console.log("Path " + pair + " [" + findPath(ids[0]*1, ids[1]*1) + "]");
  });
};
