let Hooks = {};

Hooks.TimezoneHook = {
  mounted() {
    const clientTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    this.pushEvent("client_timezone", { timezone: clientTimezone });
  }
}

export default Hooks;