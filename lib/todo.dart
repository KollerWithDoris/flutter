library todo;

class Todo{
  final who;
  final what;

  const Todo(this.who,this.what);

  void println(){
    print("who is " + "${who}" + "...what is " + "${what}");
  }
}