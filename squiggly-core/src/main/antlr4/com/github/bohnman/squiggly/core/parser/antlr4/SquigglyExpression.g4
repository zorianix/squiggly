grammar SquigglyExpression;

//-----------------------------------------------------------------------------
//region Parser Rules
//-----------------------------------------------------------------------------
nodeFilter
    : nodeExpressionList (Pipe nodeExpressionList)* EOF
    ;

propertyFilter
    : expressionList EOF
    ;

//region Expressions
expressionList
    : expression (Comma expression)*
    ;

nodeExpressionList
    : expressionList
    | topLevelExpression
    ;

expression
    : negatedExpression
    | fieldGroupExpression
    | dottedFieldExpression
    | recursiveExpression
    ;

dottedFieldExpression
    : dottedField keyValueFieldArgChain? nestedExpression?
    ;

fieldGroupExpression
    : fieldGroup nestedExpression
    | fieldGroup keyValueFieldArgChain
    | fieldGroup keyValueFieldArgChain nestedExpression
    ;

negatedExpression
    : Subtract field
    | Subtract dottedField
    ;

nestedExpression
    : SquigglyLeft expressionList? SquigglyRight
    | BracketLeft expressionList? BracketRight
    | ParenLeft expressionList? ParenRight
    ;

recursiveExpression
    : WildcardDeep keyValueFieldArgChain? (ParenLeft recursiveRange  ParenRight)?
    | WildcardDeep ParenLeft (recursiveRange Comma)? recursiveArg (Comma recursiveArg)*  ParenRight
    ;

recursiveArg
    : (fieldGroup | field) keyValueFieldArgChain?
    | Subtract? field
    ;

recursiveRange
    : recursiveRangeLeft
    | recursiveRangeRight
    | recursiveRangeBoth
    | recursiveRangeNone
    ;


recursiveRangeLeft
    : StrictIntegerLiteral (DotDot | Colon)
    ;

recursiveRangeRight
    : (DotDot | Colon)? StrictIntegerLiteral
    ;

recursiveRangeBoth
    : StrictIntegerLiteral (DotDot | Colon) StrictIntegerLiteral
    ;

recursiveRangeNone
    : DotDot | Colon
    ;



topLevelExpression
    : Dollar topLevelArgChain?
    ;

topLevelArgChain
    : assignment
    | argChainLink+
    ;
//endregion

//region Fields
dottedField
    : field (Dot field)*
    ;

field
    : Identifier
    | namedSymbol
    | RegexLiteral
    | StringLiteral
    | variable
    | wildcard
    | wildcardField
    ;

fieldGroup
    : ParenLeft field (Comma field)* ParenRight
    ;

wildcardField
   : Identifier wildcard
   | Identifier (wildcard Identifier)+ wildcard?
   | wildcard Identifier
   | wildcard (Identifier wildcard)+ Identifier?
   ;

//endregion

//region Field Arguments
continuingFieldArgChain
    :  continuingFieldArgChainLink+
    ;

continuingFieldArgChainLink
    : accessOperator function
    ;

fieldArgChain
    : (function) continuingFieldArgChain?
    ;

keyValueFieldArgChain
    : Colon (fieldArgChain | assignment) Colon (fieldArgChain| assignment)
    | Colon fieldArgChain
    | Colon assignment
    | assignment
    | fieldArgChain
    | continuingFieldArgChain
    ;

//endregion

//region Arrays
arrayDeclaration
    : At ParenLeft intRange ParenRight
    | At ParenLeft (arg (Comma arg)*)? ParenRight
    ;
//endregion

//region Assignment
assignment
    : Equals arg
    | AssignSelf arg
    | AddAssign arg
    | SubtractAssign arg
    | MultiplyAssign arg
    | DivideAssign arg
    | ModulusAssign arg
    ;
//endregion

//region Functions
functionAccessor
    : accessOperator function
    ;

function
    : functionName ParenLeft (arg (Comma arg)*)? ParenRight
    ;

functionName
    : At Identifier
    | At namedSymbol
    | At
    ;
//endregion

//region Function Arguments
arg
    : argChain
    | Null
    | lambda
    | (NotName | Not) arg
    | arg (WildcardShallow | MultiplyName | SlashForward | DivideName | Modulus | ModulusName) arg
    | arg (Add | AddName | Subtract | SubtractName) arg
    | arg (Elvis) arg
    | arg (AngleLeft | LessThanName | LessThanEquals | LessThanEqualsName | AngleRight | GreaterThanName | GreaterThanEquals | GreaterThanEqualsName) arg
    | arg (EqualsEquals | EqualsName | EqualsNot | EqualsNotSql | EqualsNotName | Match | MatchName | MatchNot | MatchNotName) arg
    | arg (And | AndName) arg
    | arg (Or | OrName) arg
    | ifArg
    | argGroupStart arg argGroupEnd argChainLink*
    ;

argChain
    : (arrayDeclaration | objectDeclaration | literal | intRange | variable | initialPropertyAccessor | function) argChainLink*
    | propertySortDirection (variable | initialPropertyAccessor | function) argChainLink*
    ;

argChainLink
    : propertyAccessor
    | functionAccessor
    ;

argGroupStart
    : ParenLeft
    ;

argGroupEnd
    : ParenRight
    ;


ifArg
    : ifClause elifClause* elseClause? End
    ;

ifClause
    : If arg Then arg
    ;

elifClause
    : Elif arg Then arg
    ;

elseClause
    : Else arg
    ;
//endregion

//region Objects
objectDeclaration
    : Pound ParenLeft (objectKeyValue (Comma objectKeyValue)*)? ParenRight
    ;

objectKeyValue
    : objectKey Colon objectValue
    ;

objectKey
    : Identifier
    | variable
    | literal
    ;

objectValue
    : arg
    ;
//endregion

//region Ranges
intRange
    : intRangeLeft
    | intRangeRight
    | intRangeBoth
    | intRangeNone
    ;

intRangeLeft
    : intRangeArg (Colon | DotDot)
    ;

intRangeRight
    : (Colon | DotDot) intRangeArg
    ;

intRangeBoth
    : intRangeArg (Colon | DotDot) intRangeArg
    ;

intRangeNone
    : Colon | DotDot
    ;

intRangeArg
    : (Add | Subtract)? IntegerLiteral
    | variable
    ;

//endregion


//region Lambdas

lambda
    : lambdaArg Lambda lambdaBody
    | ParenLeft (lambdaArg (Comma lambdaArg)*)? ParenRight Lambda lambdaBody
    | lambdaArg? Lambda lambdaBody
    ;

lambdaBody
    : arg
    ;

lambdaArg
    : variable
    | Underscore
    ;
//endregion

//region Literals

literal
    : BooleanLiteral
    | (Add | Subtract)? FloatLiteral
    | (Add | Subtract)? IntegerLiteral
    | RegexLiteral
    | StringLiteral
    ;

//region Operators

accessOperator
    : Dot
    | SafeNavigation
    ;

namedSymbol
    : AddName
    | AndName
    | SubtractName
    | MultiplyName
    | DivideName
    | Elif
    | Else
    | End
    | ModulusName
    | EqualsName
    | EqualsNotName
    | If
    | LessThanName
    | LessThanEqualsName
    | GreaterThanName
    | GreaterThanEqualsName
    | MatchName
    | MatchNotName
    | OrName
    | NotName
    | Then
    ;
//endregion

//region Properties
initialPropertyAccessor
    : (Dollar QuestionMark? Dot)? Identifier
    | (Dollar QuestionMark? ParenLeft) (StringLiteral | variable) ParenRight
    | Dollar
    ;

propertySortDirection
    : Add
    | Subtract
    ;

propertyAccessor
    : accessOperator Identifier
    | (ParenLeft | ParenLeftSafe) (StringLiteral | variable) ParenRight
    | intRange
    ;
//endregion

//region Variables
variable
    : Variable
    ;
//endregion

//region Wildcards
wildcard
    : WildcardShallow
    | QuestionMark
    ;
//endregion

//endregion

//-----------------------------------------------------------------------------
//region Lexer Tokens
//-----------------------------------------------------------------------------

//region Keywords
AddName: 'add';
AndName: 'and';
EqualsName: 'eq';
EqualsNotName: 'ne';
DivideName: 'div';
GreaterThanEqualsName: 'gte';
GreaterThanName: 'gt';
LessThanEqualsName: 'lte';
LessThanName: 'lt';
MatchName: 'match';
MatchNotName: 'nmatch';
ModulusName: 'mod';
MultiplyName: 'mul';
NotName: 'not';
OrName: 'or';
SubtractName: 'sub';
//endregion

//region Symbols
Add: '+';
AddAssign: '+=';
And: '&&';
AngleLeft: '<';
AngleRight: '>';
AssignSelf: '.=';
At: '@';
Backtick: '`';
BracketLeft: '[';
BracketLeftSafe: '?[';
BracketRight: ']';
Colon: ':';
Comma: ',';
Dollar: '$';
Dot: '.';
DotDot: '..';
DivideAssign: '/=';
Equals: '=';
EqualsEquals: '==';
EqualsNot: '!=';
EqualsNotSql: '<>';
Elif: 'elif';
Else: 'else';
Elvis: '?:';
End: 'end';
GreaterThanEquals: '>=';
If: 'if';
Lambda: '->';
LessThanEquals: '<=';
Match: '=~';
MatchNot: '!~';
Modulus: '%';
ModulusAssign: '%=';
MultiplyAssign: '*=';
Not: '!';
Null: 'null';
ParenLeft: '(';
ParenLeftSafe: '?(';
ParenRight: ')';
Pound: '#';
Pipe: '|';
QuestionMark: '?';
QuoteSingle: '\'';
QuoteDouble: '"';
SafeNavigation: '?.';
SlashForward: '/';
Subtract: '-';
SubtractAssign: '-=';
SquigglyLeft: '{';
SquigglyRight: '}';
Then: 'then';
Tilde: '~';
Underscore: '_';
WildcardShallow: '*';
WildcardDeep: '**';
Or: '||';
//endregion


//region Literals
BooleanLiteral
    : 'true'
    | 'false'
    ;

StrictIntegerLiteral
    : StrictIntegerNumeral
    ;

IntegerLiteral
    : IntegerNumeral
    ;

FloatLiteral
    : FloatNumeral
    ;

RegexLiteral
    : SlashForward RegexChar+ SlashForward RegexFlag*
    | Tilde RegexChar+ Tilde RegexFlag*
    ;

StringLiteral
    : QuoteDouble DoubleQuotedStringCharacters* QuoteDouble
    | QuoteSingle SingleQuotedStringCharacters* QuoteSingle
    | Backtick BacktickQuotedStringCharacters* Backtick
    ;


Identifier
    : IdentifierFirst (IdentifierRest)*
    ;
//endregion

//region Variables
Variable
    : Dollar Identifier
    | Dollar ParenLeft Identifier ParenRight
    | Dollar ParenLeft SquigglyString+ ParenRight
    ;
//endregion

//region Whitespace and Comments
Whitespace
    : [ \t\n\r]+ -> skip
    ;
//endregion

//endregion

//-----------------------------------------------------------------------------
//region Lexer Fragments
//-----------------------------------------------------------------------------

//region Identifiers
fragment IdentifierFirst
    : [a-zA-Z_]
    ;

fragment IdentifierRest
    : [a-zA-Z_0-9]
    ;
//endregion

//region Numbers
fragment Digit : [0-9];

fragment StrictIntegerNumeral
    : '0'
    | [1-9] Digit*
    ;

fragment IntegerNumeral
    : StrictIntegerNumeral
    | [1-9] Digit? Digit? (',' Digit Digit Digit)+
    ;

fragment FloatNumeral
    : IntegerNumeral '.' Digit+
    | '.' Digit+
    ;
//endregion


//region Regex
fragment RegexChar
    : ~[/]
    ;

fragment RegexEscape
    : '\\' [/]
    ;

fragment RegexFlag
    : 'i'
    ;
//endregion


//region Strings
fragment SquigglyString
    : (~[()\\ \t\n\r] | StringEscape)
    | (~[()\\ \t\n\r] | StringEscape) (~[()\\ \t\n\r] | StringEscape)
    | (~[()\\ \t\n\r] | StringEscape) (~[()\\] | StringEscape)+ (~[()\\ \t\n\r] | StringEscape)
    ;

fragment BacktickQuotedStringCharacters
    :    ~[`\\]
    |    StringEscape
    ;

fragment DoubleQuotedStringCharacters
    :    ~["\\]
    |    StringEscape
    ;

fragment SingleQuotedStringCharacters
    :    ~['\\]
    |    StringEscape
    ;

fragment StringEscape
    :    '\\' ["'\\]
    ;
//endregion

//endregion