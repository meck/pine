{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.pine.machine.bbb.gpio;
in
{
  options.pine.machine.bbb.gpio.enable = mkEnableOption "Enable BBB gpio cape";

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.libgpiod ];

    hardware.deviceTree.overlays = [
      {
        # Relay cape
        name = "BBORG_RELAY-00A2.dtbo";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          #include <dt-bindings/gpio/gpio.h>
          #include <dt-bindings/pinctrl/am33xx.h>

          / {
          	compatible = "ti,am335x-bone-black", "ti,am335x-bone", "ti,am33xx";
          };


          /*
           * Free up the pins used by the cape from the pinmux helpers.
           */
          &ocp {
          	P9_41_pinmux { status = "disabled"; };	/* P9_41: gpmc_a0.gpio0_20 */
          	P9_42_pinmux { status = "disabled"; };	/* P9_42: gpmc_a1.gpio0_07 */
          	P9_30_pinmux { status = "disabled"; };	/* P9_30: gpmc_be1n.gpio3_16 */
          	P9_27_pinmux { status = "disabled"; };	/* P9_27: mcasp0_fsr.gpio3_19 */
          };

          &am33xx_pinmux {
          	bb_gpio_relay_pins: pinmux_bb_gpio_relay_pins {
          		pinctrl-single,pins = <
          			AM33XX_PADCONF(AM335X_PIN_XDMA_EVENT_INTR1, PIN_OUTPUT_PULLDOWN, MUX_MODE7)	/* P9_41: Relay1 */
          			AM33XX_PADCONF(AM335X_PIN_ECAP0_IN_PWM0_OUT, PIN_OUTPUT_PULLDOWN, MUX_MODE7)	/* P9_42: Relay2 */
          			AM33XX_PADCONF(AM335X_PIN_MCASP0_AXR0, PIN_OUTPUT_PULLDOWN, MUX_MODE7)		/* P9_30: Relay3 */
          			AM33XX_PADCONF(AM335X_PIN_MCASP0_FSR, PIN_OUTPUT_PULLDOWN, MUX_MODE7)		/* P9_27: Relay4 */
          		>;
          	};
          };
        '';
        filter = "am335x-boneblack.dtb";
      }
    ];
  };
}
