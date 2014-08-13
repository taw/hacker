import java.io.PrintStream;

public class Privy
{
  public void showMeSomethingBoring()
  {
    System.out.println("this is not interesting. look elsewhere.");
  }
  private void showMeSomethingInteresting() {
    char[] c = { 'a', 'x', 'k', 'y', 'u', 'e' };
    int a = 73; int b = 391;
    String s = "";
    for (int i = 0; i < 6; i++)
      s = s + c[((i * b + (i + 8) * a) % c.length)];
    System.out.println(s);
  }
  public static void main(String[] args) {
    new Privy().showMeSomethingInteresting();
  }
}
