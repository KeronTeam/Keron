// automatically generated, do not modify

namespace keron
{

public class FlightCtrlStateToggles
{
  public static readonly sbyte gearDown = 1;
  public static readonly sbyte gearUp = 2;
  public static readonly sbyte headlight = 4;
  public static readonly sbyte killRot = 8;

  private static readonly string[] names = { "gearDown", "gearUp", "", "headlight", "", "", "", "killRot", };

  public static string Name(int e) { return names[e - gearDown]; }
};


}
