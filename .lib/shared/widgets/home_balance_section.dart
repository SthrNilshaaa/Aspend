import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/view_models/transaction_view_model.dart';
import '../../core/const/app_dimensions.dart';
import '../../widgets/balance_card.dart';
import './home_budget_progress.dart';

class HomeBalanceSection extends StatelessWidget {
  final TransactionViewModel viewModel;

  const HomeBalanceSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = !ResponsiveUtils.isMobile(context);
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(
            height: AppDimensions.paddingSmall,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingStandard,
            ),
            child: isLargeScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: BalanceCard(
                          balance: viewModel.totalBalance,
                          onBalanceUpdate: (newBalance) =>
                              viewModel.updateBalance(newBalance),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: HomeBudgetProgress(
                          viewModel: viewModel,
                          isCompact: true,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      BalanceCard(
                        balance: viewModel.totalBalance,
                        onBalanceUpdate: (newBalance) =>
                            viewModel.updateBalance(newBalance),
                      ),
                      HomeBudgetProgress(
                        viewModel: viewModel,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
