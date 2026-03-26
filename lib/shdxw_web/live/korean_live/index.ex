defmodule ShdxwWeb.KoreanLive.Index do
  use ShdxwWeb, :live_view

  alias Shdxw.Korean
  alias Shdxw.Gamification
  alias ShdxwWeb.Helpers.Cipher

  import ShdxwWeb.Components.GamificationBar
  import ShdxwWeb.Components.AppNav

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Gamification.subscribe(scope)
    end

    profile = Gamification.get_or_create_profile(scope)
    xp_progress = Gamification.xp_progress_in_level(profile.xp)
    lessons = Korean.list_lessons()
    progress = Korean.get_user_progress(scope)
    stats = Korean.get_overall_stats(scope)

    progress_map =
      Enum.reduce(progress, %{}, fn p, acc ->
        Map.put(acc, p.lesson_id, p)
      end)

    {:ok,
     socket
     |> assign(:page_title, "Coreen - Hangul")
     |> assign(:profile, profile)
     |> assign(:xp_progress, xp_progress)
     |> assign(:lessons, lessons)
     |> assign(:progress_map, progress_map)
     |> assign(:stats, stats)
     |> assign(:current_page, :korean)
     |> assign(:view, :list)
     |> assign(:current_lesson, nil)
     |> assign(:quiz_questions, [])
     |> assign(:quiz_index, 0)
     |> assign(:quiz_answers, %{})
     |> assign(:quiz_result, nil)
     |> assign(:selected_answer, nil)
     |> assign(:show_explanation, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-black">
      <div class="fixed inset-0 bg-gradient-to-br from-black via-rose-950/20 to-black pointer-events-none" />
      <div class="fixed inset-0 pointer-events-none">
        <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-rose-600/5 rounded-full blur-3xl" />
        <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-pink-600/5 rounded-full blur-3xl" />
      </div>

      <div class="relative z-20 flex items-center justify-between px-6 py-4 border-b border-white/5 bg-black/80 backdrop-blur-sm">
        <a href="/" class="text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-500 to-violet-500 tracking-wider">
          SHDXW
        </a>
      </div>

      <.gamification_bar profile={@profile} xp_progress={@xp_progress} />
      <.app_nav current_page={@current_page} current_scope={@current_scope} />

      <Layouts.flash_group flash={@flash} />

      <div class="relative z-10 px-6 py-8 mx-auto max-w-5xl">
        <div :if={@view == :list}>
          <.render_lesson_list
            lessons={@lessons}
            progress_map={@progress_map}
            stats={@stats}
            scope={@current_scope}
          />
        </div>

        <div :if={@view == :lesson}>
          <.render_lesson lesson={@current_lesson} />
        </div>

        <div :if={@view == :quiz}>
          <.render_quiz
            lesson={@current_lesson}
            questions={@quiz_questions}
            index={@quiz_index}
            answers={@quiz_answers}
            selected_answer={@selected_answer}
            show_explanation={@show_explanation}
          />
        </div>

        <div :if={@view == :result}>
          <.render_result lesson={@current_lesson} quiz_result={@quiz_result} />
        </div>
      </div>
    </div>
    """
  end

  # --- Lesson List ---

  defp render_lesson_list(assigns) do
    ~H"""
    <div class="mb-10">
      <h1 class="text-5xl font-black text-white tracking-wider mb-2">
        <span class="text-rose-500">한</span>글
        <span class="text-white/60 text-2xl ml-2">Hangul</span>
      </h1>
      <div class="w-32 h-1 bg-gradient-to-r from-rose-500 to-transparent rounded-full mb-4" />
      <p class="text-white/40 text-sm">Apprenez le Hangul en 14 jours — 15-20 min par jour</p>
    </div>

    <%!-- Overall Progress --%>
    <div class="bg-gradient-to-br from-rose-950/30 to-black border border-rose-500/20 rounded-2xl p-6 mb-8">
      <div class="flex items-center justify-between mb-3">
        <div class="text-white font-bold">Progression globale</div>
        <div class="text-rose-400 font-black">{@stats.completed}/{@stats.total} lecons</div>
      </div>
      <div class="w-full h-4 bg-white/5 rounded-full overflow-hidden mb-2">
        <div
          class="h-full bg-gradient-to-r from-rose-600 to-pink-500 rounded-full transition-all duration-1000"
          style={"width: #{@stats.percent}%"}
        />
      </div>
      <div class="flex justify-between text-xs text-white/30">
        <span>{@stats.percent}% complete</span>
        <span :if={@stats.avg_score > 0}>Score moyen: {@stats.avg_score}%</span>
      </div>
    </div>

    <%!-- Weeks --%>
    <div class="space-y-8">
      <div :for={week <- [1, 2]}>
        <h2 class="font-black text-white tracking-wider mb-4 flex items-center gap-2">
          <span class="text-rose-500">Semaine {week}</span>
          <span :if={week == 1} class="text-white/30 text-sm font-normal">— Bases du Hangul</span>
          <span :if={week == 2} class="text-white/30 text-sm font-normal">— Hangul avance</span>
        </h2>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div
            :for={lesson <- Enum.filter(@lessons, fn l -> l.day >= (week - 1) * 7 + 1 and l.day <= week * 7 end)}
            class={[
              "bg-gradient-to-br border rounded-2xl p-5 transition-all",
              lesson_card_class(lesson, @progress_map, @scope)
            ]}
          >
            <div class="flex items-center justify-between mb-2">
              <div class="flex items-center gap-3">
                <div class={[
                  "w-10 h-10 rounded-full flex items-center justify-center font-black text-sm border",
                  day_circle_class(lesson, @progress_map, @scope)
                ]}>
                  {lesson.day}
                </div>
                <div>
                  <div class="text-white font-bold text-sm">{lesson.title}</div>
                  <div class="text-white/30 text-xs">{lesson.duration_minutes} min</div>
                </div>
              </div>

              <div :if={get_progress(@progress_map, lesson.id)} class="text-right">
                <div class="text-emerald-400 text-xs font-bold">
                  {get_progress(@progress_map, lesson.id).best_score}/{get_progress(@progress_map, lesson.id).quiz_total}
                </div>
                <div class="text-emerald-400/60 text-[10px]">meilleur score</div>
              </div>
            </div>

            <p class="text-xs text-white/40 mb-3">{lesson.description}</p>

            <div class="flex items-center justify-between">
              <span class="text-xs text-amber-400/60">+{lesson.xp_reward} XP / +{lesson.gold_reward} Or</span>

              <button
                :if={Korean.is_lesson_unlocked?(@scope, lesson)}
                phx-click="start_lesson"
                phx-value-id={lesson.id}
                class={[
                  "px-4 py-1.5 rounded-xl text-xs font-bold transition-all",
                  if(get_progress(@progress_map, lesson.id),
                    do: "bg-emerald-600/20 text-emerald-300 border border-emerald-500/30 hover:bg-emerald-600/40",
                    else: "bg-rose-600/20 text-rose-300 border border-rose-500/30 hover:bg-rose-600/40"
                  )
                ]}
              >
                {if get_progress(@progress_map, lesson.id), do: "Revoir", else: "Commencer"}
              </button>

              <span
                :if={!Korean.is_lesson_unlocked?(@scope, lesson)}
                class="text-white/20 text-xs"
              >
                🔒 Verrouillee
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # --- Lesson View ---

  defp render_lesson(assigns) do
    ~H"""
    <div class="mb-6">
      <button phx-click="back_to_list" class="text-white/40 hover:text-white text-sm flex items-center gap-1 mb-4">
        ← Retour aux lecons
      </button>
      <h1 class="text-3xl font-black text-white tracking-wider mb-1">
        <span class="text-rose-500">Jour {@lesson.day}</span> — {@lesson.title}
      </h1>
      <div class="w-32 h-1 bg-gradient-to-r from-rose-500 to-transparent rounded-full mb-4" />
    </div>

    <div class="bg-gradient-to-br from-rose-950/30 to-black border border-rose-500/20 rounded-2xl p-8 mb-8">
      <div class="prose prose-invert prose-sm max-w-none korean-content">
        {Phoenix.HTML.raw(parse_lesson_content(decrypt_content(@lesson.content)))}
      </div>
    </div>

    <div class="text-center">
      <button
        phx-click="start_quiz"
        class="px-8 py-3 rounded-2xl bg-gradient-to-r from-rose-600 to-pink-600 text-white font-black text-lg hover:from-rose-500 hover:to-pink-500 transition-all shadow-lg shadow-rose-600/30"
      >
        Passer au Quiz →
      </button>
    </div>
    """
  end

  # --- Quiz ---

  defp render_quiz(assigns) do
    raw_q = Enum.at(assigns.questions, assigns.index)
    current_q = if raw_q, do: decrypt_question(raw_q), else: nil
    total = length(assigns.questions)
    assigns = assign(assigns, :current_q, current_q)
    assigns = assign(assigns, :total, total)

    ~H"""
    <div class="mb-6">
      <button phx-click="back_to_lesson" class="text-white/40 hover:text-white text-sm flex items-center gap-1 mb-4">
        ← Retour a la lecon
      </button>
      <div class="flex items-center justify-between">
        <h2 class="text-2xl font-black text-white">
          Quiz — <span class="text-rose-500">{@lesson.title}</span>
        </h2>
        <span class="text-white/40 text-sm">{@index + 1}/{@total}</span>
      </div>
      <div class="w-full h-2 bg-white/5 rounded-full overflow-hidden mt-3">
        <div
          class="h-full bg-gradient-to-r from-rose-600 to-pink-500 rounded-full transition-all duration-300"
          style={"width: #{(@index + 1) / @total * 100}%"}
        />
      </div>
    </div>

    <div :if={@current_q} class="bg-gradient-to-br from-rose-950/30 to-black border border-rose-500/20 rounded-2xl p-8 mb-6">
      <div class="text-xl font-bold text-white mb-6">{@current_q.question}</div>

      <div class="space-y-3">
        <button
          :for={option <- @current_q.options}
          phx-click="select_answer"
          phx-value-answer={option}
          disabled={@show_explanation}
          class={[
            "w-full text-left px-5 py-3 rounded-xl border transition-all text-sm font-medium",
            !@show_explanation && @selected_answer != option && "border-white/10 bg-white/5 text-white/80 hover:border-rose-500/40 hover:bg-rose-500/10",
            !@show_explanation && @selected_answer == option && "border-rose-500/50 bg-rose-500/20 text-rose-300",
            @show_explanation && option == @current_q.correct_answer && "border-emerald-500/50 bg-emerald-500/20 text-emerald-300",
            @show_explanation && option != @current_q.correct_answer && @selected_answer == option && "border-red-500/50 bg-red-500/20 text-red-300",
            @show_explanation && option != @current_q.correct_answer && @selected_answer != option && "border-white/5 bg-white/2 text-white/30"
          ]}
        >
          {option}
        </button>
      </div>

      <div :if={@show_explanation && @current_q.explanation} class="mt-4 p-4 rounded-xl bg-white/5 border border-white/10">
        <div class="text-white/60 text-sm">{@current_q.explanation}</div>
      </div>
    </div>

    <div class="flex justify-end gap-3">
      <button
        :if={@selected_answer && !@show_explanation}
        phx-click="check_answer"
        class="px-6 py-2.5 rounded-xl bg-rose-600/30 text-rose-300 font-bold hover:bg-rose-600/50 transition-all border border-rose-500/30"
      >
        Verifier
      </button>
      <button
        :if={@show_explanation && @index < @total - 1}
        phx-click="next_question"
        class="px-6 py-2.5 rounded-xl bg-rose-600/30 text-rose-300 font-bold hover:bg-rose-600/50 transition-all border border-rose-500/30"
      >
        Suivant →
      </button>
      <button
        :if={@show_explanation && @index >= @total - 1}
        phx-click="finish_quiz"
        class="px-6 py-2.5 rounded-xl bg-gradient-to-r from-rose-600 to-pink-600 text-white font-bold hover:from-rose-500 hover:to-pink-500 transition-all"
      >
        Terminer le quiz
      </button>
    </div>
    """
  end

  # --- Result ---

  defp render_result(assigns) do
    ~H"""
    <div class="max-w-lg mx-auto text-center py-12">
      <div class="text-6xl mb-6">
        {cond do
          @quiz_result.percent >= 90 -> "🏆"
          @quiz_result.percent >= 70 -> "⭐"
          @quiz_result.percent >= 50 -> "👍"
          true -> "📚"
        end}
      </div>

      <h2 class="text-3xl font-black text-white mb-2">Quiz termine !</h2>
      <div class="text-white/40 mb-6">{@lesson.title}</div>

      <div class="bg-gradient-to-br from-rose-950/30 to-black border border-rose-500/20 rounded-2xl p-8 mb-8">
        <div class="text-5xl font-black text-rose-400 mb-2">{@quiz_result.score}/{@quiz_result.total}</div>
        <div class="text-white/40 text-sm mb-4">{@quiz_result.percent}% de bonnes reponses</div>

        <div class="flex items-center justify-center gap-4">
          <div class="text-center">
            <div class="text-purple-400 font-bold">+{@quiz_result.xp_earned} XP</div>
          </div>
          <div class="text-center">
            <div class="text-amber-400 font-bold">+{@quiz_result.gold_earned} Or</div>
          </div>
        </div>

        <div :if={@quiz_result.percent >= 70} class="mt-4 text-emerald-400 text-sm font-bold">
          Lecon validee ! ✓
        </div>
        <div :if={@quiz_result.percent < 70} class="mt-4 text-amber-400 text-sm">
          Repassez la lecon pour ameliorer votre score
        </div>
      </div>

      <div class="flex justify-center gap-4">
        <button
          phx-click="back_to_lesson"
          class="px-6 py-2.5 rounded-xl bg-white/5 text-white/60 font-bold hover:bg-white/10 transition-all border border-white/10"
        >
          Revoir la lecon
        </button>
        <button
          phx-click="back_to_list"
          class="px-6 py-2.5 rounded-xl bg-rose-600/30 text-rose-300 font-bold hover:bg-rose-600/50 transition-all border border-rose-500/30"
        >
          Retour aux lecons
        </button>
      </div>
    </div>
    """
  end

  # --- Events ---

  @impl true
  def handle_event("start_lesson", %{"id" => id}, socket) do
    lesson = Korean.get_lesson_with_questions!(String.to_integer(id))

    {:noreply,
     socket
     |> assign(:current_lesson, lesson)
     |> assign(:view, :lesson)}
  end

  def handle_event("back_to_list", _, socket) do
    scope = socket.assigns.current_scope
    progress = Korean.get_user_progress(scope)
    progress_map = Enum.reduce(progress, %{}, fn p, acc -> Map.put(acc, p.lesson_id, p) end)

    {:noreply,
     socket
     |> assign(:view, :list)
     |> assign(:progress_map, progress_map)
     |> assign(:stats, Korean.get_overall_stats(scope))
     |> assign(:current_lesson, nil)
     |> assign(:quiz_result, nil)}
  end

  def handle_event("back_to_lesson", _, socket) do
    {:noreply, assign(socket, :view, :lesson)}
  end

  def handle_event("start_quiz", _, socket) do
    lesson = socket.assigns.current_lesson
    questions = lesson.quiz_questions

    {:noreply,
     socket
     |> assign(:view, :quiz)
     |> assign(:quiz_questions, questions)
     |> assign(:quiz_index, 0)
     |> assign(:quiz_answers, %{})
     |> assign(:selected_answer, nil)
     |> assign(:show_explanation, false)}
  end

  def handle_event("select_answer", %{"answer" => answer}, socket) do
    {:noreply, assign(socket, :selected_answer, answer)}
  end

  def handle_event("check_answer", _, socket) do
    index = socket.assigns.quiz_index
    answer = socket.assigns.selected_answer
    question = Enum.at(socket.assigns.quiz_questions, index)
    decrypted_q = decrypt_question(question)

    correct = answer == decrypted_q.correct_answer
    answers = Map.put(socket.assigns.quiz_answers, index, correct)

    {:noreply,
     socket
     |> assign(:quiz_answers, answers)
     |> assign(:show_explanation, true)}
  end

  def handle_event("next_question", _, socket) do
    {:noreply,
     socket
     |> assign(:quiz_index, socket.assigns.quiz_index + 1)
     |> assign(:selected_answer, nil)
     |> assign(:show_explanation, false)}
  end

  def handle_event("finish_quiz", _, socket) do
    scope = socket.assigns.current_scope
    lesson = socket.assigns.current_lesson
    answers = socket.assigns.quiz_answers
    total = length(socket.assigns.quiz_questions)
    score = Enum.count(answers, fn {_k, v} -> v end)
    percent = if total > 0, do: round(score / total * 100), else: 0

    {:ok, _progress} = Korean.complete_lesson(scope, lesson.id, score, total)

    xp_earned = round(lesson.xp_reward * score / max(total, 1))
    gold_earned = round(lesson.gold_reward * score / max(total, 1))

    profile = Gamification.get_or_create_profile(scope)

    {:noreply,
     socket
     |> assign(:view, :result)
     |> assign(:profile, profile)
     |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))
     |> assign(:quiz_result, %{
       score: score,
       total: total,
       percent: percent,
       xp_earned: xp_earned,
       gold_earned: gold_earned
     })}
  end

  # --- PubSub ---

  @impl true
  def handle_info({event, _payload}, socket)
      when event in [:xp_gained, :level_up, :streak_updated, :gold_spent] do
    scope = socket.assigns.current_scope
    profile = Gamification.get_or_create_profile(scope)

    {:noreply,
     socket
     |> assign(:profile, profile)
     |> assign(:xp_progress, Gamification.xp_progress_in_level(profile.xp))}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  # --- Helpers ---

  defp get_progress(progress_map, lesson_id) do
    Map.get(progress_map, lesson_id)
  end

  defp lesson_card_class(lesson, progress_map, scope) do
    unlocked = Korean.is_lesson_unlocked?(scope, lesson)
    completed = get_progress(progress_map, lesson.id)

    cond do
      completed -> "from-emerald-950/20 to-black border-emerald-500/20 hover:border-emerald-500/40"
      unlocked -> "from-rose-950/30 to-black border-rose-500/20 hover:border-rose-500/40"
      true -> "from-gray-950/30 to-black border-white/5 opacity-50"
    end
  end

  defp day_circle_class(lesson, progress_map, scope) do
    unlocked = Korean.is_lesson_unlocked?(scope, lesson)
    completed = get_progress(progress_map, lesson.id)

    cond do
      completed -> "border-emerald-500/50 bg-emerald-600/20 text-emerald-400"
      unlocked -> "border-rose-500/50 bg-rose-600/20 text-rose-400"
      true -> "border-white/10 bg-white/5 text-white/20"
    end
  end

  defp decrypt_content(content) do
    case Cipher.decode(content) do
      {:ok, decoded} -> decoded
      {:error, _} -> content
    end
  end

  defp decrypt_question(question) do
    %{question |
      question: decrypt_content(question.question),
      correct_answer: decrypt_content(question.correct_answer),
      options: Enum.map(question.options, &decrypt_content/1),
      explanation: if(question.explanation, do: decrypt_content(question.explanation), else: nil)
    }
  end

  defp parse_lesson_content(content) do
    content
    |> String.split("\n")
    |> Enum.map(fn line ->
      cond do
        String.starts_with?(line, "### ") ->
          "<h3 class=\"text-xl font-black text-rose-400 mt-6 mb-3\">#{String.trim_leading(line, "### ")}</h3>"

        String.starts_with?(line, "## ") ->
          "<h2 class=\"text-2xl font-black text-white mt-8 mb-4\">#{String.trim_leading(line, "## ")}</h2>"

        String.starts_with?(line, "# ") ->
          "<h1 class=\"text-3xl font-black text-white mt-8 mb-4\">#{String.trim_leading(line, "# ")}</h1>"

        String.starts_with?(line, "- ") ->
          "<li class=\"text-white/70 ml-4\">#{String.trim_leading(line, "- ")}</li>"

        String.starts_with?(line, "| ") ->
          "<div class=\"text-4xl text-center py-2 font-bold text-white\">#{String.trim(line, "| ")}</div>"

        String.starts_with?(line, "> ") ->
          "<blockquote class=\"border-l-4 border-rose-500/40 pl-4 py-2 my-3 text-white/60 italic\">#{String.trim_leading(line, "> ")}</blockquote>"

        String.starts_with?(line, "```") ->
          ""

        line == "" ->
          "<br/>"

        true ->
          "<p class=\"text-white/70 mb-2\">#{line}</p>"
      end
    end)
    |> Enum.join("\n")
  end
end
