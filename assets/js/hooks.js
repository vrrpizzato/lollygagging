let Hooks = {};

Hooks.ClientTimezoneHook = {
  mounted() {
    const clientTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    this.pushEvent("fetched_client_timezone", { timezone: clientTimezone });
  }
}

export default Hooks;