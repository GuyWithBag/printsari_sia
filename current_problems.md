ok so when i press the minus button when the product is in the cart, it wont delete it when it reaches 0. there should probably also be a delete item button.

also (InventoryProvider already exists in app.dart tho?)
Stock in error: Error: Could not find the correct Provider<InventoryProvider> above this StatefulBuilder Widget

This happens because you used a `BuildContext` that does not include the provider
of your choice. There are a few common scenarios:

- You added a new provider in your `main.dart` and performed a hot-reload.
  To fix, perform a hot-restart.

- The provider you are trying to read is in a different route.

  Providers are "scoped". So if you insert of provider inside a route, then
  other routes will not be able to access that provider.

- You used a `BuildContext` that is an ancestor of the provider you are trying to read.

  Make sure that StatefulBuilder is under your MultiProvider/Provider<InventoryProvider>.
  This usually happens when you are creating a provider and trying to read it immediately.

  For example, instead of:

  ```
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

  ```
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
  ```

If none of these solutions work, consider asking for help on StackOverflow:
https://stackoverflow.com/questions/tagged/flutter

What does this mean? is this a supabase error? https://supabase.com/docs/reference/dart/introduction
Error creating user: AuthApiException(message: Email address "dsa@printsari.internal" is invalid, statusCode: 400, code: email_address_invalid)

Please take note of using the available state management things in @pubspec.yaml
