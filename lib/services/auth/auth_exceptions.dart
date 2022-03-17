//For Login View
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

//For Register View
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//generic Exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
