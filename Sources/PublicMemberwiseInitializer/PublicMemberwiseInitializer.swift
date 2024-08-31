/// A macro that produces a public memberwise initializer
///
/// By default implicit initializers have only _internal_ or
/// more restrictive access, requiring developers to
/// write their own public initializers. This is fine when
/// dealing with only a few types, but becomes harder as
/// the number of types grows to the hundreds,
/// with frequent, automated changes by third parties.
///
/// In these conditions
/// \@PublicMemberwiseInitializer can be used
/// to facilitate managing such types.
/// For example,
/// ```
/// @PublicMemberwiseInitializer
/// public struct MyStruct {
///      let myString: String
/// }
/// ```
/// produces
/// ```
/// public struct MyStruct {
///      let myString: String
///      public init(myString: String) {
///         self.myString = myString
///      }
/// }
/// ````
///
@attached(member, names: named(init))
public macro PublicMemberwiseInitializer() = #externalMacro(module: "PublicMemberwiseInitializerMacros", type: "PublicMemberwiseInitializerMacro")
