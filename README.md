# 命題論理のシークエント計算のRuby実装

- `lib/prop.rb` : 命題クラス
- `lib/seq.rb` : シークエント
- `lib/tree.rb` : 分解木

# 使い方の例

以下のコマンドで開始

```sh
$ irb -Ilib -r seq
```

### 命題

#### X ∧ Y

```rb
x_and_y = Prop.and(Prop.str('X'), Prop.str('Y'))
## 真理値割当を指定してbool値を計算
x_and_y.eval_bool 'X' => true, 'Y' => true
# => true
x_and_y.eval_bool 'X' => true, 'Y' => false
# => false
```

#### X → Y

```rb
x_imp_y = Prop.imply(Prop.str('X'), Prop.str('Y'))
x_imp_y.eval_bool 'X' => true, 'Y' => false
# => false
x_imp_y.eval_bool 'X' => false, 'Y' => true
# => true
```

## シークエント

#### X ∧ (X → Y) → Y [modus ponens]

```rb
mp = Prop.imply(Prop.and(Prop.str('X'), x_imp_y), Prop.str('Y'))
mp_seq = Seq.new([], [mp])
mp_seq.valid? # => true
puts mp_seq.resolve_tree.to_s
# X => Y, X                      is true   [1-1-1]
# X, Y => Y                      is true   [1-1-2]
# X, X → Y => Y                  by imp-L  [1-1]
# X ∧ (X → Y) => Y               by and-L  [1]
#  => X ∧ (X → Y) → Y            by imp-R  [Goal]
```

#### ¬¬X → X [二重否定除去]

```rb
dn = Prop.imply(Prop.not(Prop.not(Prop.str('X'))), Prop.str('X'))
dn_seq = Seq.new([], [dn])
dn_seq.valid? # => true
puts dn_seq.resolve_tree.to_s
# X => X                         is true   [1-1-1]
#  => X, ¬X                      by not-R  [1-1]
# ¬¬X => X                       by not-L  [1]
#  => ¬¬X → X                    by imp-R  [Goal]
```

#### ¬(P ∨ Q) ⇔ ¬P ∧ ¬Q [De Morganの法則]

```rb
dm_left = Prop.not(Prop.or(Prop.str('P'), Prop.str('Q')))
dm_right = Prop.and(Prop.not(Prop.str('P')), Prop.not(Prop.str('Q')))
dm = Prop.imply(dm_left, dm_right)
dm_seq = Seq.new([], [dm])
dm_seq.valid?
puts dm_seq.resolve_tree.to_s
# P => P, Q                      is true   [1-1-1-1-1]
# P => P ∨ Q                     by or-R   [1-1-1-1]
# P, ¬(P ∨ Q) =>                 by not-L  [1-1-1]
# ¬(P ∨ Q) => ¬P                 by not-R  [1-1]
# Q => P, Q                      is true   [1-2-1-1-1]
# Q => P ∨ Q                     by or-R   [1-2-1-1]
# Q, ¬(P ∨ Q) =>                 by not-L  [1-2-1]
# ¬(P ∨ Q) => ¬Q                 by not-R  [1-2]
# ¬(P ∨ Q) => ¬P ∧ ¬Q            by and-R  [1]
#  => ¬(P ∨ Q) → ¬P ∧ ¬Q         by imp-R  [Goal]

dm_inv = Prop.imply(dm_left, dm_right)
dm_inv_seq = Seq.new([], [dm_inv])
dm_inv_seq.valid?
puts dm_inv_seq.resolve_tree.to_s
# P => P, Q                      is true   [1-1-1-1-1]
# P => P ∨ Q                     by or-R   [1-1-1-1]
# P, ¬(P ∨ Q) =>                 by not-L  [1-1-1]
# ¬(P ∨ Q) => ¬P                 by not-R  [1-1]
# Q => P, Q                      is true   [1-2-1-1-1]
# Q => P ∨ Q                     by or-R   [1-2-1-1]
# Q, ¬(P ∨ Q) =>                 by not-L  [1-2-1]
# ¬(P ∨ Q) => ¬Q                 by not-R  [1-2]
# ¬(P ∨ Q) => ¬P ∧ ¬Q            by and-R  [1]
#  => ¬(P ∨ Q) → ¬P ∧ ¬Q         by imp-R  [Goal]
```

#### (P -> Q) -> (Q -> R) -> (R -> P) [正しくない命題]

```rb
p2q = Prop.imply(Prop.str('P'), Prop.str('Q'))
q2r = Prop.imply(Prop.str('Q'), Prop.str('R'))
r2p = Prop.imply(Prop.str('R'), Prop.str('P'))
pqr_cycle = Prop.imply(p2q, Prop.imply(q2r, r2p))
pqr_cycle_seq = Seq.new([], [pqr_cycle])
pqr_cycle_seq.valid? # => false
puts pqr_cycle_seq.resolve_tree.to_s
# R => P, Q, P                   is false  [1-1-1-1-1]
# R, Q => P, Q                   is true   [1-1-1-1-2]
# R, P → Q => P, Q               by imp-L  [1-1-1-1]
# R, R => P, P                   is false  [1-1-1-2-1]
# R, R, Q => P                   is false  [1-1-1-2-2]
# R, R, P → Q => P               by imp-L  [1-1-1-2]
# R, Q → R, P → Q => P           by imp-L  [1-1-1]
# Q → R, P → Q => R → P          by imp-R  [1-1]
# P → Q => Q → R → R → P         by imp-R  [1]
#  => P → Q → Q → R → R → P      by imp-R  [Goal]
```
