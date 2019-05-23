part of ranges;

abstract class _NumRange extends _Range<num> {
  // ignore: avoid_positional_boolean_parameters
  _NumRange(num start, num end, bool startInclusive, bool endInclusive, bool finite) :
        super(start, end, startInclusive, endInclusive, finite);
  _NumRange._(bool finite) : super._(finite);
}
