import 'package:lognito/lognito.dart';

final Lognito logger = Lognito.init(
    buffer: FilteredBuffer(
        <Output>[ConsoleOutput(formatter: PrettyFormatter())],
        filter: DevelopmentFilter(Level.info)));
