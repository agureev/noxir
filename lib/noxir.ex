defmodule Noxir do
  @moduledoc """
  I am a basic Nock interpreter with comments for educational use.

  Below you can find some docs and comments regarding what each of the
  nock flags 0-11 do.

  ## General Notes:

  ### Subject
  Do not think of the subject in [subject formula] as an
  actual input to a function, as you will not encounter usual
  name-allocation for that. It will only make your life harder.

  Instead think of subject as a context in type theory or as a stack.

  Things get added to the stack and you can make some operation with
  them once they are availiable. As in type theory, these are not
  exactly always something that you will use for your results or
  function applications, but they will be availiable. Similarly your
  variable declarations will not be named, they will instead just be a
  value in a context.

  ### Recursion

  Basic recursion on one natural number can be made sense if you start
  designing it with starting the formula as:

  [
    [
      body_of_recursion (for example an 'if' statement)
      [initial_val user_input]
    ]
    loop_implementation (probably a 9 statement)
  ]

  From this, you can start thinking about implementing a recursive
  function.

  ## Knowledge assumed
  Binary Trees (index combinatorics)
  Basic Elixir Syntax (pattern-matching, typespec)
  """

  require Integer

  @typedoc """
  An atom in a natural number
  """
  @type atom_nock :: non_neg_integer()

  @typedoc """
  A cell is an improper list of nouns
  """
  @type cell_nock :: nonempty_maybe_improper_list()

  @typedoc """
  A noun is either an atom or a cell

  The inductive definition would be, in pseducode:

  data noun : Type where
  atom : Nat -> noun
  cell : noun -> noun -> noun
  """
  @type noun :: atom_nock | cell_nock

  @typedoc """
  Nock result is either a noun or a crash.
  """
  @type maybe_noun :: noun | :crash

  @doc """
  is_cell? asks whether the argument is a nock cell or not.
  0 if yes, 1 if false.

  ? operator in the specs
  """

  @spec is_cell?(nonempty_maybe_improper_list() | integer()) :: 0 | 1
  def is_cell?([_tl | _hd]) do
    0
  end

  def is_cell?(x) when is_integer(x) do
    1
  end

  @doc """
  The increment function adds 1 to a nock atom supplied.

  + operator in the specs
  """

  @spec inc(any()) :: maybe_noun()
  def inc(x) when is_integer(x) do
    x + 1
  end

  def inc(_x) do
    # Cells cannot be incremented
    :crash
  end

  @doc """
  Given a cell, asks whether its 2nd and 3rd index are equal or not.

  = operator in the specs
  """

  @spec is_eq?(any()) :: maybe_noun()
  def is_eq?([a | b]) do
    if a == b do
      0
    else
      1
    end
  end

  def is_eq?(_x) do
    # atom canot be compared
    :crash
  end

  @doc """
  Given an index, find a leaf of that index in the specified tree.

  \ operator in the specs.
  """
  def find_at([1 | tree]) do
    tree
  end

  def find_at([2 | [left_branch | _right_branch]]) do
    left_branch
  end

  def find_at([3 | [_left_branch | right_branch]]) do
    right_branch
  end

  def find_at([index | tree]) do
    if Integer.is_even(index) do
      # If even, we are looking for the left branch somewhere.
      # The (index / 2) index actually reffers to the parent of the
      # left branch we are looking for.

      parent_index = div(index, 2)
      parent = find_at([parent_index | tree])

      # So we search for the left branch (2) of the parent of
      # said element, which we know by inductive hypothesis is
      # find_at (index / 2) of the original tree

      find_at([2 | parent])
    else
      # If odd, we are looking for the right branch somewhere.
      # ((index - 1) / 2) actually is the index of the parent of the
      # right branch we are looking for.

      parent_index = div(index - 1, 2)
      parent = find_at([parent_index | tree])

      # So we are searching for the right branch (3) of of the
      # parent of said branch, which is by inducrive hypothesis
      # found by find_at n-1 / 2 of the tail

      find_at([3 | parent])
    end
  end

  def find_at(_x) do
    # if no index exists, then crash
    :crash
  end

  @doc """
  Replace_at [n new_leaf old_tree] replaces the nth index in the
  old-tree by a new leaf

  # operator in the specs
  """

  @spec replace_at(any()) :: maybe_noun()
  def replace_at([1 | [new_leaf | _old_tree]]) do
    # Replacing at index 1 means replacing the entire tree

    new_leaf
  end

  def replace_at([index | [new_leaf | old_tree]]) do
    if Integer.is_even(index) do
      # if the index is even, we want to replace the left branch
      # of something in the old tree. If it is a left branch, there
      # is also a right branch. It will be easier to replace the
      # entire cell, i.e. the parent of the branch we want to replace
      # at that index

      # so first find the right branch, i.e. (index + 1)

      right_branch = find_at([index + 1, old_tree])

      # form the cell to be replaced

      new_cell = [new_leaf | right_branch]

      # Now we need to replace the old cell. Note that its index will be
      # actually half as we defined above. The parent is always twice the left
      # brach's index. So we need to replace new_cell in the old_tree at index
      # half, which we can do by the inducive hypothesis

      parent_cell_index = div(index, 2)
      replace_at([parent_cell_index | [new_cell | old_tree]])
    else
      # if the index is odd, then we want to replace the right banch of some cell
      # so there is a left branch, which has (index - 1)

      left_branch_index = index - 1

      # let us find it

      left_branch = find_at([left_branch_index, old_tree])

      # so the cell to be replaced becomes

      new_cell = [left_branch | new_leaf]

      # now we need to place this new cell into the old tree at
      # where the original cell of the left branch is. as the left branch's index is
      # index - 1 then its parent has index index-1 / 2

      parent_cell_index = div(left_branch_index, 2)

      # by inductive hypothesis we know how to replace the old tree at that address

      replace_at([parent_cell_index | [new_cell | old_tree]])
    end
  end

  @doc """
  Definition of Nock as a function taking a noun andproducing either a noun or crashing.

  * operation in the specs.
  """

  @spec nock(any()) :: maybe_noun()
  def nock([a | [0 | b]]) do
    find_at([b | a])
  end

  def nock([_a | [1 | b]]) do
    b
  end

  def nock([a | [2 | [b | c]]]) do
    eval_first = nock([a | b])
    eval_second = nock([a | c])

    nock([eval_first | eval_second])
  end

  def nock([a | [3 | b]]) do
    eval = nock([a | b])
    is_cell?(eval)
  end

  def nock([a | [4 | b]]) do
    eval = nock([a | b])
    inc(eval)
  end

  def nock([a | [5 | [b | c]]]) do
    eval_first = nock([a | b])
    eval_second = nock([a | c])

    is_eq?([eval_first | eval_second])
  end

  def nock([a | [6 | [b | [c | d]]]]) do
    # this is the if-then-else functionality of nock
    # so we want to evaluate b against a and see whether
    # it gives 0 (true) or 1 (false)

    # if it gives 0, we want to execute [a | c]
    # if it gives 1, we want to execute [a | d]

    # so we want a formulata of sort [a | find_at(2_or_3, [c, d])]
    # so that if [a | b] is true, then we pick c to execute,
    # otherwise d

    # how do we get 2_or_3 from [a | b]? we increment is twice, of course
    # we do this by applying 4 twice

    # in the simplified version, we can do it like this:
    # a \[+(+(*[a b])) [c d]]]
    # or, using our syntax:

    true_or_false = [a | b] |> nock()
    two_or_three = true_or_false |> inc() |> inc()
    c_or_d =  find_at([two_or_three | [c | d]])
    _simp_nock_6 =  [a | c_or_d] |> nock()

    # but what if [a | b] is not boolean? Nock does not have such type-chekcing
    # info beforehand, so we want it to crash automatically before any such lookup
    # however if [c d] have subcells if index +(+(*[a b])) > 3 it will instead
    # produce a subcell of c or d rather than c or d instead

    # we will fix this by first looking up the +(+(*[a b])) index in [2 3]
    # this way we will automatically crash if [a b] is not a boolean

    # so let us then trace these steps forward:

    # first we get the increment
    #  nock([a | [4 | [4 | b]]]) ==
    #  inc(nock([a | [4 | b]])) ==
    #  inc(inc(nock([a | b]))) == eval_b_at_a_plus_two

    eval_b_at_a_plus_two = [a | [4 | [4 | b]]] |> nock()

    # then we look up the index in [2 3]
    # nock([[2 3] 0 (eval_b_at_a_plus_two)])
    # find eval_b_at_a + 2 in [2 3]
    # if [a | b] is true, this is 2
    # if false, this is 3
    # otherwise, we crash as the deepest index of `[2 3]` is 3

    find_index = [[2 | 3] | [0 | eval_b_at_a_plus_two]]

    # nock([[c d] | [0 | 2_or_3]]
    # find_at(2_or_3 | [c | d])
    # so picks either c or d

    [a | [[c | d] | [0 | find_index]]] |> nock
  end

  def nock([a | [7 | [b | c]]]) do
    eval_b_at_a = [a | b] |> nock()
    [eval_b_at_a | c] |> nock()
  end

  def nock([a | [8 | [b = formula_to_get_assignment | c]]]) do
    eval_b_at_a = [a | b] |> nock
    variable_and_old_body = [eval_b_at_a | a]

    # The canonical way to have an assignment is just adding a new
    # value to the subject. So if subject was a not we have
    # [new_var a]

    # For example, setting a new variable equal to 0 to a subject with
    # [1 2] is [0 [1 2]]

    # [a 8 b c] mean "add a value of *[a b] to the context and use c
    # on it"

    # if a variable does not need to use the subjects, then b will be
    # of form [1 n] where n is the value to be assigned

    # the point in evaluating against the subject is that the variable
    # to be pushed may use the stack to generate new asisgnment as in
    # a = a + 1


    # read [a [8 [1 n] formula]] as "push n to the stack" and then
    # execute g

    # read [8 [1 n]] as "push n to the stack"

    # read [8 fun] as "push a function to the stack" after evaluating in
    # at the current stack

    [variable_and_old_body | c] |> nock()
  end

  def nock([a = core | [9 | [b = index_of_formula_in_core | c = what_to_do_with_core]]]) do
    # *[a c] 2 [0 1] 0 b
    eval_c_at_a = [a | c] |> nock()

    # pick_top = do nothing to the core
    pick_top = [0 | 1]
    pick_at_b = [0 | b]

    # Core is just a cell whose tail is data (possibly containing other
    # cores) and whose head is code (containing one or more formulas)

    # The lingo is: [battery payload] or [bat pay]
    # a formula inside a core is called an arm

    # The canonical way to use a core: pick a formula out of the battery
    # then use the formula on the entire core, i.e. [[bat pay] \[n bat]]

    # 9 is used to efficiently use cores
    # b here is the position of the formuala we wont to use in the core
    # a

    # The point is not that the core OUGHT to be the subject, it is that
    # we usually want to keep it around as a stash to our formular and
    # "pre-compiled" data. So we might alter it also using formula c

    # So if we want to operate solely on the core with formula of index
    # n in bat we do [[bat pay] 9 2n [0 1]]

    # what happens if we want to loop on natural numbers, e.g.?
    # for loops on natural numbers we need some current value on which
    # we loop val ,the input in and some function which tests what to
    # do on current val with given input

    # in this case a = [formula [val input]]
    # where formula will also be a 9 statement
    # that will change the val
    # 9 2 0 1 = keep the context unchanged and take its left branch as
    # the formula to be evaluated against the context

    # when the loop goes up, you usually change [0 1] into a function
    # which changes the changes the context you operate on. if we are
    # recursing on atoms, this usually increments the elemnt by 1

    # equivalent to *[*[a c] *[*[a c] 0 b]]
    [eval_c_at_a | [2 | [pick_top | pick_at_b]]] |> nock()
  end

  def nock([a | [10 | [[b | c] | d]]]) do
    eval_c_at_a = [a | c] |> nock()
    eval_d_at_a = [a | d] |> nock()
    replace_at([b | [ eval_c_at_a | eval_d_at_a]])
  end

  def nock([a | [11 | [[_b | c] | d]]]) do
    eval_d_at_a = [a | d] |> nock()
    eval_c_at_a = [a | c] |> nock()
    pick_left = [0 | 3]

    [[eval_c_at_a | eval_d_at_a] | pick_left]
  end

  def nock([a | [11 | [_b | c]]])  do
    [a | c] |> nock()
  end

  def nock(_x) do
    :crash
  end
end
