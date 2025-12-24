import 'package:flutter/material.dart';
import '../models/page_response.dart';

class InfiniteScrollPaginator<T> extends StatefulWidget {
  final Future<PageResponse<T>> Function(int page, int size) fetchPage;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final int pageSize;
  final Widget? noItemsFoundIndicator;
  final Widget? loader;

  const InfiniteScrollPaginator({
    Key? key,
    required this.fetchPage,
    required this.itemBuilder,
    this.pageSize = 20,
    this.noItemsFoundIndicator,
    this.loader,
  }) : super(key: key);

  @override
  InfiniteScrollPaginatorState<T> createState() => InfiniteScrollPaginatorState<T>();
}

class InfiniteScrollPaginatorState<T> extends State<InfiniteScrollPaginator<T>> {
  final ScrollController _scrollController = ScrollController();
  final List<T> _items = [];
  int _currentPage = 0;
  bool _isLastPage = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isScrollAtBottom() && !_isLoading && !_isLastPage) {
      _fetchPage();
    }
  }

  bool _isScrollAtBottom() {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9); // Trigger at 90% scroll
  }

  Future<void> _fetchPage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pageResponse = await widget.fetchPage(_currentPage, widget.pageSize);
      
      if (mounted) {
        setState(() {
          _items.addAll(pageResponse.content);
          _isLastPage = pageResponse.last;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void refresh() {
    setState(() {
      _items.clear();
      _currentPage = 0;
      _isLastPage = false;
      _error = null;
    });
    _fetchPage();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      if (_isLoading) {
        return widget.loader ?? const Center(child: CircularProgressIndicator());
      }
      if (_error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              ElevatedButton(onPressed: refresh, child: const Text('Reintentar')),
            ],
          ),
        );
      }
      return widget.noItemsFoundIndicator ?? 
             const Center(child: Text('No hay elementos para mostrar'));
    }

    return RefreshIndicator(
      onRefresh: () async => refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + (_isLastPage ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            if (_error != null) {
               return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: ElevatedButton(onPressed: _fetchPage, child: const Text('Reintentar carga')),
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return widget.itemBuilder(context, _items[index]);
        },
      ),
    );
  }
}
