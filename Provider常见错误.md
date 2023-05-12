出现异常。
ProviderNotFoundException (Error: Could not find the correct Provider<SlatePickerState> above this Consumer<SlatePickerState> Widget

This happens because you used a `BuildContext` that does not include the provider
of your choice. There are a few common scenarios:

- You added a new provider in your `main.dart` and performed a hot-reload.
  To fix, perform a hot-restart.

- The provider you are trying to read is in a different route.

  Providers are "scoped". So if you insert of provider inside a route, then
  other routes will not be able to access that provider.

- You used a `BuildContext` that is an ancestor of the provider you are trying to read.

  Make sure that Consumer<SlatePickerState> is under your MultiProvider/Provider<SlatePickerState>.
  This usually happens when you are creating a provider and trying to read it immediately.

  For example, instead of:

  ```dart
  Widget build(BuildContext context) {
    return Provider<Example>(
      create: (_) => Example(),
      // Will throw a ProviderNotFoundError, because `context` is associated
      // to the widget that is the parent of `Provider<Example>`
      child: Text(context.watch<Example>().toString()),
    );
  }
  ```

  consider using `builder` like so:

  ```dart
  Widget build(BuildContext context) {
    return Provider<Example>(
      create: (_) => Example(),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return Text(context.watch<Example>().toString());
      }
    );
  }

  Provider<RecordFileNum>.value(
      value: num,
      builder: (context, child){ 
        return 

    // final _num = Provider.of<RecordFileNum>(context, listen: false);
  ```