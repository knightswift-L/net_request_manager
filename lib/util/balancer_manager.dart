import 'dart:async';
import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';

Future<LoadBalancer> sBalancer = LoadBalancer.create(2, IsolateRunner.spawn);

Future<R> balancerExecute<R, P>(R Function(P argument) function, P argument) async {
  LoadBalancer balancer = await sBalancer;
  return balancer.run(function, argument);
}
